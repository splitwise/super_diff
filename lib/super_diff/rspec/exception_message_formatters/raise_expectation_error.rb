module SuperDiff
  module RSpec
    module ExceptionMessageFormatters
      class RaiseExpectationError < Base
        def self.regex
          /\A\(.+\)\..+\(.+\)\s+expected: (\d+) times? with (any) arguments\s+received: (\d+) times with (any) arguments\Z/.freeze
        end

        protected

        def colors
          [:beta, :beta, :alpha, :alpha]
        end
      end
    end
  end
end
