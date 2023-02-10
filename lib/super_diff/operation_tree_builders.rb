module SuperDiff
  module OperationTreeBuilders
    autoload :Array, "super_diff/operation_tree_builders/array"
    autoload :Base, "super_diff/operation_tree_builders/base"
    autoload :CustomObject, "super_diff/operation_tree_builders/custom_object"
    autoload :DefaultObject, "super_diff/operation_tree_builders/default_object"
    autoload :Hash, "super_diff/operation_tree_builders/hash"
    autoload :Main, "super_diff/operation_tree_builders/main"
    # TODO: Where is this used?
    autoload(
      :MultilineString,
      "super_diff/operation_tree_builders/multiline_string"
    )
    autoload :TimeLike, "super_diff/operation_tree_builders/time_like"
  end
end

require "super_diff/operation_tree_builders/defaults"
