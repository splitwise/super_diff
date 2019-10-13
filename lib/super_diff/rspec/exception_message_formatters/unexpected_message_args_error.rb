module SuperDiff
  module RSpec
    module ExceptionMessageFormatters
      class UnexpectedMessageArgsError < Base
        def self.regex
          /\A(.+) received (:\w+) with unexpected arguments\s+expected: (\(.+\))\s+got: (\(.+\))\Z/.freeze
        end

        # colorize /.+/, :generic
        # skip " received "
        # colorize /:\w+/, :generic
        # skip " with unexpected arguments\s"
        # skip "expected: "
        # colorize /\(.+\)/, :alpha
        # skip "\s+got: "
        # colorize /\(.+\)/, :beta

        protected

        def colors
          [:generic, :generic, :alpha, :beta]
        end
      end
    end
  end
end
