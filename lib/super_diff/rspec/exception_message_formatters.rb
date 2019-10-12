module SuperDiff
  module RSpec
    module ExceptionMessageFormatters
      autoload :Base, "super_diff/rspec/exception_message_formatters/base"
      autoload :Default, "super_diff/rspec/exception_message_formatters/default"
      autoload(
        :RaiseExpectationError,
        "super_diff/rspec/exception_message_formatters/raise_expectation_error",
      )
    end
  end
end
