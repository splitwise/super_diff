# frozen_string_literal: true

module SuperDiff
  module Basic
    module OperationTreeFlatteners
      autoload :Array, 'super_diff/basic/operation_tree_flatteners/array'
      autoload(
        :Collection,
        'super_diff/basic/operation_tree_flatteners/collection'
      )
      autoload(
        :CustomObject,
        'super_diff/basic/operation_tree_flatteners/custom_object'
      )
      autoload(
        :DefaultObject,
        'super_diff/basic/operation_tree_flatteners/default_object'
      )
      autoload :Hash, 'super_diff/basic/operation_tree_flatteners/hash'
      autoload(
        :MultilineString,
        'super_diff/basic/operation_tree_flatteners/multiline_string'
      )
    end
  end
end
