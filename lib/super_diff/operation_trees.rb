module SuperDiff
  module OperationTrees
    autoload :Array, "super_diff/operation_trees/array"
    autoload :Base, "super_diff/operation_trees/base"
    autoload :CustomObject, "super_diff/operation_trees/custom_object"
    autoload :DefaultObject, "super_diff/operation_trees/default_object"
    autoload :Hash, "super_diff/operation_trees/hash"
    autoload :Main, "super_diff/operation_trees/main"
    autoload :MultilineString, "super_diff/operation_trees/multiline_string"
  end
end

require "super_diff/operation_trees/defaults"
