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
    def self.differ
      SuperDiff::RSpec::Differ
    end

    module ExpectationHelper
      def self.handle_failure(matcher, message, failure_message_method)
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

  module Core
    module Formatters
      module ConsoleCodes
        # Patch so it returns nothing if code_or_symbol is nil, and that it uses
        # code_or_symbol if it can't be found in VT100_CODE_VALUES to allow for
        # customization
        def self.console_code_for(code_or_symbol)
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
        def self.wrap(text, code_or_symbol)
          if RSpec.configuration.color_enabled? && code = console_code_for(code_or_symbol)
            "\e[#{code}m#{text}\e[0m"
          else
            text
          end
        end
      end

      class ExceptionPresenter
        # UPDATE: Copy from SyntaxHighlighter::CodeRayImplementation
        RESET_CODE = "\e[0m"

        def initialize(exception, example, options={})
          @exception               = exception
          @example                 = example
          # Patch to use no color by default
          # TODO: Only use color if no diff is being printed
          @message_color           = options[:message_color]
          @description             = options.fetch(:description)            { example.full_description }
          @detail_formatter        = options.fetch(:detail_formatter)       { Proc.new {} }
          @extra_detail_formatter  = options.fetch(:extra_detail_formatter) { Proc.new {} }
          @backtrace_formatter     = options.fetch(:backtrace_formatter)    { RSpec.configuration.backtrace_formatter }
          @indentation             = options.fetch(:indentation, 2)
          @skip_shared_group_trace = options.fetch(:skip_shared_group_trace, false)
          @failure_lines           = options[:failure_lines]
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

        # Style the first part in white and don't style the snippet of the line
        def failure_slash_error_lines
          lines = read_failed_lines

          failure_slash_error = ConsoleCodes.wrap(
            "Failure/Error: ",
            :white
          )

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

      class SyntaxHighlighter
        private

        def implementation
          RSpec::Core::Formatters::SyntaxHighlighter::NoSyntaxHighlightingImplementation
        end
      end
    end
  end

  module Support
    class ObjectFormatter
      # Override to use our formatting algorithm
      def format(value)
        SuperDiff::ObjectInspection.inspect(value, as_single_line: true)
      end
    end
  end

  module Matchers
    class ExpectedsForMultipleDiffs
      # Add a key for different sides
      def self.from(expected)
        return expected if self === expected

        text =
          colorizer.wrap("Diff:", :white) +
          "\n\n" +
          colorizer.wrap("┌ (Key) ──────────────────────────┐", :blue) +
          "\n" +
          colorizer.wrap("│ ", :blue) +
          colorizer.wrap("‹-› in expected, not in actual", :failure) +
          colorizer.wrap("  │", :blue) +
          "\n" +
          colorizer.wrap("│ ", :blue) +
          colorizer.wrap("‹+› in actual, not in expected", :success) +
          colorizer.wrap("  │", :blue) +
          "\n" +
          colorizer.wrap("│ ", :blue) +
          "‹ › in both expected and actual" +
          colorizer.wrap(" │", :blue) +
          "\n" +
          colorizer.wrap("└─────────────────────────────────┘", :blue)

        new([[expected, text]])
      end

      def self.colorizer
        RSpec::Core::Formatters::ConsoleCodes
      end

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

    module BuiltIn
      class Be
        prepend SuperDiff::RSpec::AugmentedMatcher

        prepend(Module.new do
          def expected_for_failure_message
            "truthy"
          end
        end)
      end

      class BeComparedTo
        prepend SuperDiff::RSpec::AugmentedMatcher

        prepend(Module.new do
          def expected_action
            "#{@operator}"
          end
        end)
      end

      class BeTruthy
        prepend SuperDiff::RSpec::AugmentedMatcher

        prepend(Module.new do
          def expected_action
            "be"
          end

          def expected_for_failure_message
            "truthy"
          end
        end)
      end

      class BeFalsey
        prepend SuperDiff::RSpec::AugmentedMatcher

        prepend(Module.new do
          def expected_action
            "be"
          end

          def expected_for_failure_message
            "falsey"
          end
        end)
      end

      class BeNil
        prepend SuperDiff::RSpec::AugmentedMatcher

        prepend(Module.new do
          def expected_action
            "be"
          end

          def expected_for_failure_message
            "nil"
          end
        end)
      end

      class BePredicate
        prepend SuperDiff::RSpec::AugmentedMatcher

        prepend(Module.new do
          def actual_for_failure_message
            actual
          end

          def expected_for_failure_message
            expected
          end

          def expected_action
            "return true for"
          end

          # Override to use a custom template builder
          def failure_message_template_builder
            @_failure_message_template_builder ||=
              SuperDiff::RSpec::FailureMessageBuilders::BePredicate.new(
                actual: actual_for_failure_message,
                expected: expected_for_failure_message,
                expected_action: expected_action,
                predicate_accessible: predicate_accessible?,
                private_predicate: private_predicate?,
                expected_predicate_method_name: predicate
              )
          end
        end)
      end

      class Eq
        prepend SuperDiff::RSpec::AugmentedMatcher
      end

      class Equal
        prepend SuperDiff::RSpec::AugmentedMatcher
      end

      class ContainExactly
        prepend SuperDiff::RSpec::AugmentedMatcher

        prepend(Module.new do
          # Override this method so that the differ knows that this is a partial
          # collection
          def expected_for_diff
            matchers.a_collection_containing_exactly(*expected)
          end

          private

          # Override to use readable_list_of
          def expected_for_description
            readable_list_of(expected).lstrip
          end

          # Override to use raw expected value
          def expected_for_failure_message
            expected
          end

          def failure_message_template_builder_class
            SuperDiff::RSpec::FailureMessageBuilders::ContainExactly
          end
        end)
      end

      class Include
        prepend SuperDiff::RSpec::AugmentedMatcher

        prepend(Module.new do
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
            readable_list_of(@divergent_items).lstrip
          end

          # Update to use (...) as delimiter instead of {...}
          def readable_list_of(items)
            if items.all? { |item| item.is_a?(Hash) }
              description_of(items.inject(:merge)).
                sub(/^\{ /, '(').
                sub(/ \}$/, ')')
            else
              super
            end
          end
        end)
      end

      class Match
        prepend SuperDiff::RSpec::AugmentedMatcher

        prepend(Module.new do
          def failure_message_template_builder
            @_failure_message_template_builder ||=
              SuperDiff::RSpec::FailureMessageBuilders::Match.new(
                actual: actual_for_failure_message,
                expected: expected_for_failure_message,
                expected_action: expected_action,
                expected_captures: @expected_captures
              )
          end
        end)
      end

      class HaveAttributes
        prepend SuperDiff::RSpec::AugmentedMatcher

        prepend(Module.new do
          # Use the message in the base matcher
          def failure_message
            respond_to_failure_message_or { super }
          end

          # Use the message in the base matcher
          def failure_message_when_negated
            respond_to_failure_message_or { super }
          end

          # Override to use the whole object, not just part of it
          def actual_for_failure_message
            description_of(@actual)
          end

          # Override to use (...) as delimiters rather than {...}
          def expected_for_failure_message
            super.sub(/^\{ /, '(').gsub(/ \}$/, ')')
          end
          alias_method :expected_for_description, :expected_for_failure_message

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
        end)

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

      class RespondTo
        prepend SuperDiff::RSpec::AugmentedMatcher

        prepend(Module.new do
          # Override to use a custom template builder
          def failure_message_template_builder
            @_failure_message_template_builder ||=
              SuperDiff::RSpec::FailureMessageBuilders::RespondTo.new(
                actual: actual_for_failure_message,
                expected: expected_for_failure_message,
                expected_action: expected_action,
                expected_arity: @expected_arity,
                arbitrary_keywords: @arbitrary_keywords,
                expected_keywords: @expected_keywords,
                unlimited_arguments: @unlimited_arguments
              )
          end

          # Override to use this
          def expected_for_failure_message
            @failing_method_names
          end
        end)
      end

      class RaiseError
        prepend SuperDiff::RSpec::AugmentedMatcher

        prepend(Module.new do
          def actual_for_failure_message
            "#<#{@actual_error.class.name} #{@actual_error.message.inspect}>"
          end

          def actual_for_diff
            @actual_error.message
          end

          def expected_for_failure_message
            if @expected_message
              "#<#{@expected_error.name} #{@expected_message.inspect}>"
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

          def expected_action
            "match"
          end

          def failure_message_template_builder_class
            SuperDiff::RSpec::FailureMessageBuilders::RaiseError
          end
        end)

        def self.matcher_name
          'raise error'
        end
      end
    end
  end
end
