module SuperDiff
  module Errors
    autoload(
      :NoDiffFormatterAvailableError,
      "super_diff/errors/no_diff_formatter_available_error",
    )
    autoload(
      :NoDifferAvailableError,
      "super_diff/errors/no_differ_available_error",
    )
    autoload(
      :NoOperationalSequenceAvailableError,
      "super_diff/errors/no_operational_sequencer_available_error",
    )
  end
end
