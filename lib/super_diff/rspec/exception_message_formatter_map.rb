module SuperDiff
  module RSpec
    class ExceptionMessageFormatterMap
      class NotFoundError < StandardError; end

      def call(exception_message)
        strategies = [
          ExceptionMessageFormatters::ExpectationError,
          ExceptionMessageFormatters::UnexpectedMessageArgsError,
          ExceptionMessageFormatters::Default,
        ]

        found_strategy = strategies.find do |strategy|
          strategy.applies_to?(exception_message)
        end

        found_strategy or raise NotFoundError.new(
          "Could not find an appropriate formatter class!",
        )
      end
    end
  end
end
