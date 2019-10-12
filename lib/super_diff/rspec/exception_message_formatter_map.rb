module SuperDiff
  module RSpec
    class ExceptionMessageFormatterMap
      class NotFoundError < StandardError; end

      def call(exception_message)
        strategies = [
          ExceptionMessageFormatters::RaiseExpectationError,
          ExceptionMessageFormatters::Default,
        ]

        found_strategy = strategies.find do |strategy|
          strategy.applies_to?(exception_message)
        end

        if found_strategy
          found_strategy#.call(exception.message)
        else
          raise NotFoundError.new(
            "Could not find an appropriate formatter class!",
          )
        end
      end
    end
  end
end
