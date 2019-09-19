module SuperDiff
  module RSpec
    module MatcherTextBuilders
      class RaiseError < Base
        protected

        def actual_phrase
          "Expected raised exception"
        end
      end
    end
  end
end
