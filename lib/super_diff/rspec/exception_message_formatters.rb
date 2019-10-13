module SuperDiff
  module RSpec
    module ExceptionMessageFormatters
      autoload :Base, "super_diff/rspec/exception_message_formatters/base"
      autoload :Default, "super_diff/rspec/exception_message_formatters/default"
      autoload(
        :ExpectationError,
        "super_diff/rspec/exception_message_formatters/expectation_error",
      )
      autoload(
        :UnexpectedMessageArgsError,
        "super_diff/rspec/exception_message_formatters/unexpected_message_args_error",
      )
    end
  end
end
