module SuperDiff
  module RSpec
    module MatcherTextBuilders
      class BePredicate < Base
        def initialize(
          predicate_accessible:,
          private_predicate:,
          expected_predicate_method_name:,
          **rest
        )
          super(**rest)
          @predicate_accessible = predicate_accessible
          @private_predicate = private_predicate
          @expected_predicate_method_name = expected_predicate_method_name
        end

        protected

        def expected_action_for_failure_message
          if predicate_accessible?
            "return a truthy result for"
          elsif private_predicate?
            "have a public method"
          else
            "respond to"
          end
        end

        def actual_color
          :yellow
        end

        def add_actual_value
          template.add_text_in_color(actual_color) { description_of(actual) }
        end

        def add_expected_value_to_failure_message(template)
          template.add_text " "
          template.add_text_in_color(
            expected_color,
            "#{expected_for_failure_message}?"
          )
          template.add_text " or "
          template.add_text_in_color(
            expected_color,
            "#{expected_for_failure_message}s?"
          )
        end

        def add_expected_value_to_description(template)
          template.add_text " "
          template.add_text_in_color(
            expected_color,
            "`#{expected_for_description}?`"
          )
          template.add_text " or "
          template.add_text_in_color(
            expected_color,
            "`#{expected_for_description}s?`"
          )
        end

        def add_extra_after_error
          if expected_predicate_method_name == :true?
            template.add_text "\n\n"
            template.add_text "(Perhaps you want to use "
            template.add_text_in_color(:blue, "be(true)")
            template.add_text " or "
            template.add_text_in_color(:blue, "be_truthy")
            template.add_text " instead?)"
          elsif expected_predicate_method_name == :false?
            template.add_text "\n\n"
            template.add_text "(Perhaps you want to use "
            template.add_text_in_color(:blue, "be(false)")
            template.add_text " or "
            template.add_text_in_color(:blue, "be_falsey")
            template.add_text " instead?)"
          end
        end

        private

        attr_reader :expected_predicate_method_name

        def predicate_accessible?
          @predicate_accessible
        end

        def private_predicate?
          @private_predicate
        end
      end
    end
  end
end
