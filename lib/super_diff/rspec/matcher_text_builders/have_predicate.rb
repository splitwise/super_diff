module SuperDiff
  module RSpec
    module MatcherTextBuilders
      class HavePredicate < Base
        def initialize(predicate_accessible:, private_predicate:, **rest)
          super(**rest)
          @predicate_accessible = predicate_accessible
          @private_predicate = private_predicate
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
            expected_for_failure_message
          )
        end

        def add_expected_value_to_description(template)
          template.add_text " "
          template.add_text_in_color(
            expected_color,
            "`#{expected_for_description}`"
          )
        end

        private

        def private_predicate?
          @private_predicate
        end

        def predicate_accessible?
          @predicate_accessible
        end
      end
    end
  end
end
