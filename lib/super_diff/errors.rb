module SuperDiff
  module Errors
    autoload(
      :NoDiffFormatterAvailableError,
      "super_diff/errors/no_diff_formatter_available_error"
    )
    autoload(
      :NoDifferAvailableError,
      "super_diff/errors/no_differ_available_error"
    )
    autoload(
      :NoOperationTreeBuilderAvailableError,
      "super_diff/errors/no_operation_tree_builder_available_error"
    )
  end
end
