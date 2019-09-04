module SuperDiff
  module RSpec
    module FailureMessageBuilders
      class RaiseError < Base
        protected

        def actual_phrase
          "Expected raised exception"
        end
      end
    end
  end
end
