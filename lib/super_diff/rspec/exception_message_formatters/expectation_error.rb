module SuperDiff
  module RSpec
    module ExceptionMessageFormatters
      class ExpectationError < Base
        def self.regex
          /\A\(.+\)\..+\(.+\)\s+expected: (\d+) times? with (any) arguments\s+received: (\d+) times with (any) arguments\Z/.freeze
        end

        protected

        def colors
          [:alpha, :alpha, :beta, :beta]
        end
      end
    end
  end
end
