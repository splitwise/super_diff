require "super_diff/active_support"

module SuperDiff
  module ActiveRecord
    autoload :Differs, "super_diff/active_record/differs"
    autoload(
      :ObjectInspection,
      "super_diff/active_record/object_inspection",
    )
    autoload(
      :OperationTrees,
      "super_diff/active_record/operation_trees",
    )
    autoload(
      :OperationTreeBuilders,
      "super_diff/active_record/operation_tree_builders",
    )
    autoload(
      :OperationTreeFlatteners,
      "super_diff/active_record/operation_tree_flatteners",
    )

    SuperDiff.configure do |config|
      config.add_extra_differ_classes(
        Differs::ActiveRecordRelation,
      )
      config.add_extra_operation_tree_builder_classes(
        OperationTreeBuilders::ActiveRecordModel,
        OperationTreeBuilders::ActiveRecordRelation,
      )
      config.add_extra_inspection_tree_builder_classes(
        ObjectInspection::InspectionTreeBuilders::ActiveRecordModel,
        ObjectInspection::InspectionTreeBuilders::ActiveRecordRelation,
      )
    end
  end
end

require "super_diff/active_record/monkey_patches"
