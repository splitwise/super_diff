# frozen_string_literal: true

module SuperDiff
  module Basic
    module OperationTrees
      autoload :Array, 'super_diff/basic/operation_trees/array'
      autoload :CustomObject, 'super_diff/basic/operation_trees/custom_object'
      autoload :DefaultObject, 'super_diff/basic/operation_trees/default_object'
      autoload :Hash, 'super_diff/basic/operation_trees/hash'
      autoload(
        :MultilineString,
        'super_diff/basic/operation_trees/multiline_string'
      )

      class Main
        def self.call(*args)
          warn <<~WARNING
            WARNING: SuperDiff::OperationTrees::Main.call(...) is deprecated and will be removed in the next major release.
            Please use SuperDiff.find_operation_tree_for(...) instead.
            #{caller_locations.join("\n")}
          WARNING
          SuperDiff.find_operation_tree_for(*args)
        end
      end
    end
  end
end
