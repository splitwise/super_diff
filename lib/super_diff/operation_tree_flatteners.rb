module SuperDiff
  module OperationTreeFlatteners
    autoload :Array, "super_diff/operation_tree_flatteners/array"
    autoload :Base, "super_diff/operation_tree_flatteners/base"
    autoload :Collection, "super_diff/operation_tree_flatteners/collection"
    autoload(
      :CustomObject,
      "super_diff/operation_tree_flatteners/custom_object",
    )
    autoload(
      :DefaultObject,
      "super_diff/operation_tree_flatteners/default_object",
    )
    autoload :Hash, "super_diff/operation_tree_flatteners/hash"
    autoload(
      :MultilineString,
      "super_diff/operation_tree_flatteners/multiline_string",
    )
  end
end
