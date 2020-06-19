module SuperDiff
  module ActiveSupport
    autoload :Differs, "super_diff/active_support/differs"
    autoload :ObjectInspection, "super_diff/active_support/object_inspection"
    autoload(
      :OperationTrees,
      "super_diff/active_support/operation_trees",
    )
    autoload(
      :OperationTreeBuilders,
      "super_diff/active_support/operation_tree_builders",
    )
    autoload(
      :OperationTreeFlatteners,
      "super_diff/active_support/operation_tree_flatteners",
    )

    SuperDiff.configure do |config|
      config.add_extra_differ_classes(
        Differs::HashWithIndifferentAccess,
      )
      config.add_extra_operation_tree_builder_classes(
        OperationTreeBuilders::HashWithIndifferentAccess,
      )
      config.add_extra_inspection_tree_builder_classes(
        ObjectInspection::InspectionTreeBuilders::HashWithIndifferentAccess,
      )
    end
  end
end
