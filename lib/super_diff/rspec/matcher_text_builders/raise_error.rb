module SuperDiff
  module RSpec
    module MatcherTextBuilders
      class RaiseError < Base
        protected

        def actual_phrase
          if actual
            "Expected raised exception"
          else
            "Expected"
          end
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
