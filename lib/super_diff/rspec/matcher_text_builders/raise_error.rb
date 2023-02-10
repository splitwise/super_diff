module SuperDiff
  module RSpec
    module MatcherTextBuilders
      class RaiseError < Base
        protected

        def actual_phrase
          actual ? "Expected raised exception" : "Expected"
        end

        def add_actual_value
          if actual
            template.add_text_in_color(actual_color) { actual }
          else
            template.add_text("block")
          end
        end
      end
    end
  end
end
