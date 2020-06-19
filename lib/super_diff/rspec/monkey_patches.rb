# rubocop:disable all
require "rspec/matchers"
require "rspec/expectations/fail_with"
require "rspec/expectations/handler"
require "rspec/support/object_formatter"
require "rspec/matchers/built_in/be"
require "rspec/matchers/built_in/contain_exactly"
require "rspec/matchers/built_in/eq"
require "rspec/matchers/built_in/have_attributes"
require "rspec/matchers/built_in/include"
require "rspec/matchers/built_in/match"

module RSpec
  module Expectations
    SuperDiff.insert_singleton_overrides(self) do
      def differ
        SuperDiff::RSpec::Differ
      end
    end

    module ExpectationHelper
      SuperDiff.insert_singleton_overrides(self) do
        def handle_failure(matcher, message, failure_message_method)
          message = message.call if message.respond_to?(:call)
          message ||= matcher.__send__(failure_message_method)

          if matcher.respond_to?(:diffable?) && matcher.diffable?
            # Look for expected_for_diff and actual_for_diff if possible
            expected =
              if matcher.respond_to?(:expected_for_diff)
                matcher.expected_for_diff
              else
                matcher.expected
              end

            actual =
              if matcher.respond_to?(:actual_for_diff)
                matcher.actual_for_diff
              else
                matcher.actual
              end

            ::RSpec::Expectations.fail_with(message, expected, actual)
          else
            ::RSpec::Expectations.fail_with(message)
          end
        end
      end
    end
  end

  module Core
    module Formatters
      module ConsoleCodes
        SuperDiff.insert_singleton_overrides(self) do
          # Patch so it returns nothing if code_or_symbol is nil, and that it uses
          # code_or_symbol if it can't be found in VT100_CODE_VALUES to allow for
          # customization
          def console_code_for(code_or_symbol)
            if code_or_symbol
              if (config_method = config_colors_to_methods[code_or_symbol])
                console_code_for RSpec.configuration.__send__(config_method)
              elsif RSpec::Core::Formatters::ConsoleCodes::VT100_CODE_VALUES.key?(code_or_symbol)
                code_or_symbol
              else
                RSpec::Core::Formatters::ConsoleCodes::VT100_CODES.fetch(code_or_symbol) do
                  code_or_symbol
                end
              end
            end
          end

          # Patch so it does not apply a color if code_or_symbol is nil
          def wrap(text, code_or_symbol)
            if RSpec.configuration.color_enabled? && code = console_code_for(code_or_symbol)
              "\e[#{code}m#{text}\e[0m"
            else
              text
            end
          end
        end
      end

      class ExceptionPresenter
        # UPDATE: Copy from SyntaxHighlighter::CodeRayImplementation
        RESET_CODE = "\e[0m"

        SuperDiff.insert_overrides(self) do
          def initialize(exception, example, options={})
            @exception               = exception
            @example                 = example
            @message_color           = options.fetch(:message_color)          { RSpec.configuration.failure_color }
            @description             = options.fetch(:description)            { example.full_description }
            @detail_formatter        = options.fetch(:detail_formatter)       { Proc.new {} }
            @extra_detail_formatter  = options.fetch(:extra_detail_formatter) { Proc.new {} }
            @backtrace_formatter     = options.fetch(:backtrace_formatter)    { RSpec.configuration.backtrace_formatter }
            @indentation             = options.fetch(:indentation, 2)
            @skip_shared_group_trace = options.fetch(:skip_shared_group_trace, false)
            # Patch to convert options[:failure_lines] to groups
            if options.include?(:failure_lines)
              @failure_line_groups = [
                {
                  lines: options[:failure_lines],
                  already_colorized: false
                }
              ]
            end
          end

          # Override to only color uncolored lines in red
          # and to not color empty lines
          def colorized_message_lines(colorizer = ::RSpec::Core::Formatters::ConsoleCodes)
            lines = failure_line_groups.flat_map do |group|
              if group[:already_colorized]
                group[:lines]
              else
                group[:lines].map do |line|
                  if line.strip.empty?
                    line
                  else
                    indentation = line[/^[ ]+/]
                    rest = colorizer.wrap(line.sub(/^[ ]+/, ''), message_color)

                    if indentation
                      indentation + rest
                    else
                      rest
                    end
                  end
                end
              end
            end

            add_shared_group_lines(lines, colorizer)
          end

          private

          def add_shared_group_lines(lines, colorizer)
            return lines if @skip_shared_group_trace

            example.metadata[:shared_group_inclusion_backtrace].each do |frame|
              # Use red instead of the default color
              lines << colorizer.wrap(frame.description, :failure)
            end

            lines
          end

          # Considering that `failure_slash_error_lines` is already colored,
          # extract this from the other lines so that they, too, can be colored,
          # later
          #
          # TODO: Refactor this somehow
          #
          def failure_line_groups
            if defined?(@failure_line_groups)
              @failure_line_groups
            else
              @failure_line_groups = [
                {
                  lines: failure_slash_error_lines,
                  already_colorized: true
                }
              ]

              sections = [failure_slash_error_lines, exception_lines]
              separate_groups = (
                sections.any? { |section| section.size > 1 } &&
                !exception_lines.first.empty?
              )

              if separate_groups
                @failure_line_groups << { lines: [''], already_colorized: true }
              end

              already_colorized = exception_lines.any? do |line|
                SuperDiff::Csi.already_colorized?(line)
              end

              if already_colorized
                @failure_line_groups << {
                  lines: exception_lines,
                  already_colorized: true
                }
              else
                locatable_exception_lines =
                  exception_lines.each_with_index.map do |line, index|
                    { text: line, index: index }
                  end

                boundary_line =
                  locatable_exception_lines.find do |line, index|
                    line[:text].strip.empty? || line[:text].match?(/^    /)
                  end

                if boundary_line
                  @failure_line_groups << {
                    lines: exception_lines[0..boundary_line[:index] - 1],
                    already_colorized: false
                  }
                  @failure_line_groups << {
                    lines: exception_lines[boundary_line[:index]..-1],
                    already_colorized: true
                  }
                else
                  @failure_line_groups << {
                    lines: exception_lines,
                    already_colorized: false
                  }
                end
              end

              @failure_line_groups
            end
          end

          # Style the first part in white and don't style the snippet of the line
          def failure_slash_error_lines
            lines = read_failed_lines

            failure_slash_error = ConsoleCodes.wrap("Failure/Error: ", :bold)

            if lines.count == 1
              lines[0] = failure_slash_error + lines[0].strip
            else
              least_indentation = SnippetExtractor.least_indentation_from(lines)
              lines = lines.map do |line|
                line.sub(/^#{least_indentation}/, '  ')
              end
              lines.unshift(failure_slash_error)
            end

            lines
          end

          # Exclude this file from being included in backtraces, so that the
          # SnippetExtractor prints the right thing
          def find_failed_line
            line_regex = RSpec.configuration.in_project_source_dir_regex
            loaded_spec_files = RSpec.configuration.loaded_spec_files

            exception_backtrace.find do |line|
              next unless (line_path = line[/(.+?):(\d+)(|:\d+)/, 1])
              path = File.expand_path(line_path)
              path != __FILE__ && (loaded_spec_files.include?(path) || path =~ line_regex)
            end || exception_backtrace.first
          end
        end
      end

      class SyntaxHighlighter
        SuperDiff.insert_overrides(self) do
          private

          def implementation
            RSpec::Core::Formatters::SyntaxHighlighter::NoSyntaxHighlightingImplementation
          end
        end
      end
    end
  end

  module Support
    class ObjectFormatter
      SuperDiff.insert_singleton_overrides(self) do
        # Override to use our formatting algorithm
        def format(value)
          SuperDiff.inspect_object(value, as_lines: false)
        end
      end

      SuperDiff.insert_overrides(self) do
        # Override to use our formatting algorithm
        def format(value)
          SuperDiff.inspect_object(value, as_lines: false)
        end
      end
    end
  end

  module Matchers
    class ExpectedsForMultipleDiffs
      SuperDiff.insert_singleton_overrides(self) do
        # Add a key for different sides
        def from(expected)
          return expected if self === expected

          text =
            colorizer.wrap("Diff:", SuperDiff.configuration.header_color) +
            "\n\n" +
            colorizer.wrap(
              "┌ (Key) ──────────────────────────┐",
              SuperDiff.configuration.border_color
            ) +
            "\n" +
            colorizer.wrap("│ ", SuperDiff.configuration.border_color) +
            colorizer.wrap(
              "‹-› in expected, not in actual",
              SuperDiff.configuration.expected_color
            ) +
            colorizer.wrap("  │", SuperDiff.configuration.border_color) +
            "\n" +
            colorizer.wrap("│ ", SuperDiff.configuration.border_color) +
            colorizer.wrap(
              "‹+› in actual, not in expected",
              SuperDiff.configuration.actual_color
            ) +
            colorizer.wrap("  │", SuperDiff.configuration.border_color) +
            "\n" +
            colorizer.wrap("│ ", SuperDiff.configuration.border_color) +
            "‹ › in both expected and actual" +
            colorizer.wrap(" │", SuperDiff.configuration.border_color) +
            "\n" +
            colorizer.wrap(
              "└─────────────────────────────────┘",
              SuperDiff.configuration.border_color
            )

          new([[expected, text]])
        end

        def colorizer
          RSpec::Core::Formatters::ConsoleCodes
        end
      end

      SuperDiff.insert_overrides(self) do
        # Add an extra line break
        def message_with_diff(message, differ, actual)
          diff = diffs(differ, actual)

          if diff.empty?
            message
          else
            "#{message.rstrip}\n\n#{diff}"
          end
        end

        private

        # Add extra line breaks in between diffs, and colorize the word "Diff"
        def diffs(differ, actual)
          @expected_list.map do |(expected, diff_label)|
            diff = differ.diff(actual, expected)
            next if diff.strip.empty?
            diff_label + diff
          end.compact.join("\n\n")
        end
      end
    end

    module BuiltIn
      class Be
        SuperDiff.insert_overrides(self, SuperDiff::RSpec::AugmentedMatcher)

        SuperDiff.insert_overrides(self) do
          def expected_for_matcher_text
            "truthy"
          end
        end
      end

      class BeComparedTo
        SuperDiff.insert_overrides(self, SuperDiff::RSpec::AugmentedMatcher)

        SuperDiff.insert_overrides(self) do
          def expected_action_for_matcher_text
            if [:==, :===, :=~].include?(@operator)
              "#{@operator}"
            else
              "be #{@operator}"
            end
          end
        end
      end

      class BeFalsey
        SuperDiff.insert_overrides(self, SuperDiff::RSpec::AugmentedMatcher)

        SuperDiff.insert_overrides(self) do
          def expected_action_for_matcher_text
            "be"
          end

          def expected_for_matcher_text
            "falsey"
          end
        end
      end

      class BeNil
        SuperDiff.insert_overrides(self, SuperDiff::RSpec::AugmentedMatcher)

        SuperDiff.insert_overrides(self) do
          def expected_action_for_matcher_text
            "be"
          end

          def expected_for_matcher_text
            "nil"
          end
        end
      end

      class BePredicate
        SuperDiff.insert_overrides(self, SuperDiff::RSpec::AugmentedMatcher)

        SuperDiff.insert_overrides(self) do
          def actual_for_matcher_text
            actual
          end

          def expected_for_matcher_text
            if SuperDiff::RSpec.rspec_version < "3.10"
              expected
            else
              predicate.to_s.chomp('?')
            end
          end

          def expected_action_for_matcher_text
            "return true for"
          end

          def matcher_text_builder_class
            SuperDiff::RSpec::MatcherTextBuilders::BePredicate
          end

          def matcher_text_builder_args
            super.merge(
              predicate_accessible: predicate_accessible?,
              private_predicate: private_predicate?,
              expected_predicate_method_name: predicate
            )
          end
        end
      end

      class BeTruthy
        SuperDiff.insert_overrides(self, SuperDiff::RSpec::AugmentedMatcher)

        SuperDiff.insert_overrides(self) do
          def expected_action_for_matcher_text
            "be"
          end

          def expected_for_matcher_text
            "truthy"
          end
        end
      end

      class ContainExactly
        SuperDiff.insert_overrides(self, SuperDiff::RSpec::AugmentedMatcher)

        SuperDiff.insert_overrides(self) do
          # Override this method so that the differ knows that this is a partial
          # collection
          def expected_for_diff
            matchers.a_collection_containing_exactly(*expected)
          end

          private

          def expected_for_matcher_text
            expected
          end

          def matcher_text_builder_class
            SuperDiff::RSpec::MatcherTextBuilders::ContainExactly
          end
        end
      end

      class Eq
        SuperDiff.insert_overrides(self, SuperDiff::RSpec::AugmentedMatcher)
      end

      class Equal
        SuperDiff.insert_overrides(self, SuperDiff::RSpec::AugmentedMatcher)
      end

      class HaveAttributes
        SuperDiff.insert_overrides(self, SuperDiff::RSpec::AugmentedMatcher)

        SuperDiff.insert_overrides(self) do
          def initialize(*)
            super
            @actual = nil
          end

          # Use the message in the base matcher
          def failure_message
            respond_to_failure_message_or { super }
          end

          # Use the message in the base matcher
          def failure_message_when_negated
            respond_to_failure_message_or { super }
          end

          # Override to use the whole object, not just part of it
          def actual_for_matcher_text
            description_of(@actual)
          end

          # Override to use (...) as delimiters rather than {...}
          def expected_for_matcher_text
            super.sub(/^\{ /, '(').gsub(/ \}$/, ')')
          end

          # Override so that the differ knows that this is a partial object
          def actual_for_diff
            @actual
          end

          # Override so that the differ knows that this is a partial object
          def expected_for_diff
            if respond_to_failed
              matchers.an_object_having_attributes(
                @expected.select { |k, v| !@actual.respond_to?(k) }
              )
            else
              matchers.an_object_having_attributes(@expected)
            end
          end

          # Override to force @values to get populated so that we can show a
          # proper diff
          def respond_to_attributes?
            cache_all_values
            matches = respond_to_matcher.matches?(@actual)
            @respond_to_failed = !matches
            matches
          end

          # Override this method to skip non-existent attributes, and to use
          # public_send
          def cache_all_values
            @values = @expected.keys.inject({}) do |hash, attribute_key|
              if @actual.respond_to?(attribute_key)
                actual_value = @actual.public_send(attribute_key)
                hash.merge(attribute_key => actual_value)
              else
                hash
              end
            end
          end

          def actual_has_attribute?(attribute_key, attribute_value)
            values_match?(attribute_value, @values.fetch(attribute_key))
          end

          # Override to not improve_hash_formatting
          def respond_to_failure_message_or
            if respond_to_failed
              respond_to_matcher.failure_message
            else
              yield
            end
          end
        end
      end

      class Has
        SuperDiff.insert_overrides(self, SuperDiff::RSpec::AugmentedMatcher)

        SuperDiff.insert_overrides(self) do
          def actual_for_matcher_text
            actual
          end

          def expected_for_matcher_text
            if SuperDiff::RSpec.rspec_version < "3.10"
              "#{predicate}#{failure_message_args_description}"
            else
              "#{predicate}#{args_to_s}"
            end
          end

          def expected_action_for_matcher_text
            "return true for"
          end

          def matcher_text_builder_class
            SuperDiff::RSpec::MatcherTextBuilders::HavePredicate
          end

          def matcher_text_builder_args
            super.merge(
              predicate_accessible: predicate_accessible?,
              private_predicate: private_predicate?
            )
          end
        end
      end

      class Include
        SuperDiff.insert_overrides(self, SuperDiff::RSpec::AugmentedMatcher)

        SuperDiff.insert_overrides(self) do
          def initialize(*)
            super
            @actual = nil
          end

          # Override this method so that the differ knows that this is a partial
          # array or hash
          def expected_for_diff
            if expecteds.all? { |item| item.is_a?(Hash) }
              matchers.a_collection_including(expecteds.first)
            else
              matchers.a_collection_including(*expecteds)
            end
          end

          private

          # Override to capitalize message and add period at end
          def build_failure_message(negated:)
            message = super

            if actual.respond_to?(:include?)
              message
            elsif message.end_with?(".")
              message.sub("\.$", ", ") + "but it does not respond to `include?`."
            else
              message + "\n\nBut it does not respond to `include?`."
            end
          end

          # Override to use readable_list_of
          def expected_for_description
            readable_list_of(expecteds).lstrip
          end

          # Override to use readable_list_of
          def expected_for_failure_message
            # TODO: Switch to using @divergent_items and handle this in the text
            # builder
            if defined?(@divergent_items)
              readable_list_of(@divergent_items).lstrip
            else
              ""
            end
          end

          # Update to use (...) as delimiter instead of {...}
          def readable_list_of(items)
            if items && items.all? { |item| item.is_a?(Hash) }
              description_of(items.inject(:merge)).
                sub(/^\{ /, '(').
                sub(/ \}$/, ')')
            else
              super
            end
          end
        end
      end

      class Match
        SuperDiff.insert_overrides(self, SuperDiff::RSpec::AugmentedMatcher)

        SuperDiff.insert_overrides(self) do
          def matcher_text_builder_class
            SuperDiff::RSpec::MatcherTextBuilders::Match
          end

          def matcher_text_builder_args
            super.merge(expected_captures: @expected_captures)
          end
        end
      end

      class MatchArray < ContainExactly
        def expected_for_diff
          matchers.an_array_matching(expected)
        end

        def expected_action_for_matcher_text
          "match array with"
        end
      end

      class RaiseError
        SuperDiff.insert_overrides(self, SuperDiff::RSpec::AugmentedMatcher)

        SuperDiff.insert_overrides(self) do
          def actual_for_matcher_text
            if @actual_error
              "#<#{@actual_error.class.name} #{@actual_error.message.inspect}>"
            end
          end

          def actual_for_diff
            if @actual_error
              @actual_error.message
            end
          end

          def expected_for_matcher_text
            if @expected_message
              "#<#{@expected_error.name} #{description_of(@expected_message)}>"
            elsif @expected_error.is_a? Regexp
              "#<Exception #{description_of(@expected_error)}>"
            else
              "#<#{@expected_error.name}>"
            end
          end

          def expected_for_diff
            @expected_message
          end

          def diffable?
            !@expected_message.to_s.empty?
          end

          def expected_action_for_failure_message
            if @actual_error
              "match"
            else
              "raise error"
            end
          end

          def matcher_text_builder_class
            SuperDiff::RSpec::MatcherTextBuilders::RaiseError
          end
        end

        def self.matcher_name
          "raise error"
        end
      end

      class RespondTo
        SuperDiff.insert_overrides(self, SuperDiff::RSpec::AugmentedMatcher)

        SuperDiff.insert_overrides(self) do
          def initialize(*)
            super
            @failing_method_names = nil
          end

          def matcher_text_builder_class
            SuperDiff::RSpec::MatcherTextBuilders::RespondTo
          end

          def matcher_text_builder_args
            super.merge(
              expected_arity: @expected_arity,
              arbitrary_keywords: @arbitrary_keywords,
              expected_keywords: @expected_keywords,
              unlimited_arguments: @unlimited_arguments
            )
          end

          def expected_for_description
            @names
          end

          def expected_for_failure_message
            @failing_method_names
          end
        end
      end
    end

    SuperDiff.insert_overrides(self) do
      def self.prepended(base)
        base.class_eval do
          alias_matcher :an_array_matching, :match_array
        end
      end

      def match_array(items)
        BuiltIn::MatchArray.new(items.is_a?(String) ? [items] : items)
      end
    end
  end
end
