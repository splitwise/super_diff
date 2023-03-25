module SuperDiff
  module RSpec
    module MatcherTextBuilders
      class Base
        def initialize(
          actual:,
          expected_for_failure_message:,
          expected_for_description:,
          expected_action_for_failure_message:,
          expected_action_for_description:
        )
          @actual = actual
          @expected_for_failure_message = expected_for_failure_message
          @expected_for_description = expected_for_description
          @expected_action_for_failure_message =
            expected_action_for_failure_message
          @expected_action_for_description = expected_action_for_description

          @negated = nil
          @template = MatcherTextTemplate.new
        end

        def call(negated:)
          @negated = negated

          fill_template
          template.to_s
        end

        def matcher_description
          template =
            MatcherTextTemplate.new do |t|
              t.add_text expected_action_for_description
              add_expected_value_to_description(t)
              add_extra_after_expected_to(t)
            end

          Csi.decolorize(template.to_s(as_single_line: true))
        end

        protected

        def add_extra_after_expected_to(template)
        end

        def add_extra_after_error
        end

        def actual_color
          SuperDiff.configuration.actual_color
        end

        def expected_color
          SuperDiff.configuration.expected_color
        end

        private

        attr_reader(
          :actual,
          :expected_for_failure_message,
          :expected_for_description,
          :expected_action_for_failure_message,
          :expected_action_for_description,
          :template
        )

        def negated?
          @negated
        end

        def fill_template
          add_actual_section
          template.add_break
          template.insert expected_section
          add_extra_after_expected_to(template)
          template.add_text_in_singleline_mode "."
          add_extra_after_error
        end

        def add_actual_section
          template.add_text_in_singleline_mode actual_phrase
          template.add_text_in_multiline_mode do
            actual_phrase.rjust(phrase_width)
          end
          template.add_text " "
          add_actual_value
        end

        def actual_phrase
          "Expected"
        end

        def add_actual_value
          template.add_text_in_color(actual_color) { actual }
        end

        def expected_section
          MatcherTextTemplate.new do |t|
            t.add_text_in_singleline_mode expected_phrase
            t.add_text_in_multiline_mode do
              expected_phrase.to_s.rjust(phrase_width)
            end
            add_expected_value_to_failure_message(t)
          end
        end

        def add_expected_value_to_failure_message(template)
          if respond_to?(:add_expected_value_to, true)
            add_expected_value_to(template, expected_for_failure_message)
          else
            template.add_text " "
            template.add_text_in_color(
              expected_color,
              expected_for_failure_message
            )
          end
        end

        def add_expected_value_to_description(template)
          if respond_to?(:add_expected_value_to, true)
            add_expected_value_to(template, expected_for_description)
          else
            template.add_text " "
            template.add_text_in_color(expected_color, expected_for_description)
          end
        end

        def expected_phrase
          "#{to_or_not_to} #{expected_action_for_failure_message}"
        end

        def to_or_not_to
          negated? ? "not to" : "to"
        end

        def phrase_width
          [actual_phrase, expected_phrase].map do |text|
              Csi.decolorize(text.to_s).length
            end
            .max
        end

        # TODO: Should this be applied to expected and actual automatically
        # instead of expecting the caller to pass in already formatted versions
        # of those objects?
        def description_of(object)
          ::RSpec::Support::ObjectFormatter.format(object)
        end
      end
    end
  end
end
