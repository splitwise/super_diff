# frozen_string_literal: true

module SuperDiff
  module Basic
    module OperationTreeBuilders
      autoload :Array, 'super_diff/basic/operation_tree_builders/array'
      autoload(
        :CustomObject,
        'super_diff/basic/operation_tree_builders/custom_object'
      )
      autoload(
        :DataObject,
        'super_diff/basic/operation_tree_builders/data_object'
      )
      autoload(
        :DefaultObject,
        'super_diff/basic/operation_tree_builders/default_object'
      )
      autoload :Hash, 'super_diff/basic/operation_tree_builders/hash'
      # TODO: Where is this used?
      autoload(
        :MultilineString,
        'super_diff/basic/operation_tree_builders/multiline_string'
      )
      autoload :TimeLike, 'super_diff/basic/operation_tree_builders/time_like'
      autoload :DateLike, 'super_diff/basic/operation_tree_builders/date_like'

      class Main
        def self.call(*args)
          warn <<~WARNING
            WARNING: SuperDiff::OperationTreeBuilders::Main.call(...) is deprecated and will be removed in the next major release.
            Please use SuperDiff.build_operation_tree_for(...) instead.
            #{caller_locations.join("\n")}
          WARNING
          SuperDiff.build_operation_tree_for(*args)
        end
      end
    end
  end
end
