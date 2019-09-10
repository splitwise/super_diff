module SuperDiff
  module RSpec
    module FailureMessageBuilders
      class Base
        def initialize(actual:, expected:, description_as_phrase:)
          @actual = actual
          @expected = expected
          @description_as_phrase = description_as_phrase

          @template = FailureMessageTemplate.new
        end

        def call(negated:)
          @negated = negated

          fill_template
          template.to_s
        end

        def matcher_description
          Csi.decolorize(expected_section.to_s(as_single_line: true))
        end

        protected

        def add_extra
        end

        def actual_color
          :success
        end

        def expected_color
          :failure
        end

        private

        attr_reader :expected, :actual, :description_as_phrase, :template

        def negated?
          @negated
        end

        def fill_template
          add_actual_section
          template.add_break
          template.insert expected_section
          add_extra
          template.add_text_in_singleline_mode "."
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
          FailureMessageTemplate.new do |t|
            t.add_text_in_singleline_mode expected_phrase
            t.add_text_in_multiline_mode do
              if phrase_width
                expected_phrase.to_s.rjust(phrase_width)
              else
                expected_phrase
              end
            end
            t.add_text " "
            add_expected_value_to(t)
          end
        end

        def expected_phrase
          "#{to_or_not_to} #{description_as_phrase}"
        end

        def add_expected_value_to(template)
          template.add_text_in_color(expected_color) { expected }
        end

        def to_or_not_to
          if negated?
            "not to"
          else
            "to"
          end
        end

        def phrase_width
          [actual_phrase, expected_phrase].
            map { |text| Csi.decolorize(text.to_s).length }.
            max
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
