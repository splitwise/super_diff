# frozen_string_literal: true

require 'super_diff/basic/differs'
require 'super_diff/basic/inspection_tree_builders'
require 'super_diff/basic/operation_tree_builders'
require 'super_diff/basic/operation_tree_flatteners'
require 'super_diff/basic/operation_trees'

module SuperDiff
  module Basic
    autoload :DiffFormatters, 'super_diff/basic/diff_formatters'

    SuperDiff.configuration.tap do |config|
      config.add_extra_differ_classes(
        Differs::Array,
        Differs::Hash,
        Differs::TimeLike,
        Differs::DateLike,
        Differs::MultilineString,
        Differs::CustomObject,
        Differs::DefaultObject
      )

      config.add_extra_inspection_tree_builder_classes(
        InspectionTreeBuilders::CustomObject,
        InspectionTreeBuilders::Array,
        InspectionTreeBuilders::Hash,
        InspectionTreeBuilders::Primitive,
        InspectionTreeBuilders::TimeLike,
        InspectionTreeBuilders::DateLike,
        InspectionTreeBuilders::DataObject,
        InspectionTreeBuilders::RangeObject,
        InspectionTreeBuilders::DefaultObject
      )

      config.add_extra_operation_tree_builder_classes(
        OperationTreeBuilders::Array,
        OperationTreeBuilders::Hash,
        OperationTreeBuilders::TimeLike,
        OperationTreeBuilders::DateLike,
        OperationTreeBuilders::CustomObject,
        OperationTreeBuilders::DataObject
      )

      config.add_extra_operation_tree_classes(
        OperationTrees::Array,
        OperationTrees::Hash,
        OperationTrees::CustomObject,
        OperationTrees::DefaultObject
      )
    end
  end
end
