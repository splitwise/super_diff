module SuperDiff
  module ActiveSupport
    autoload :DiffFormatters, "super_diff/active_support/diff_formatters"
    autoload :Differs, "super_diff/active_support/differs"
    autoload :ObjectInspection, "super_diff/active_support/object_inspection"
    autoload(
      :OperationTreeBuilders,
      "super_diff/active_support/operation_tree_builders",
    )
    autoload(
      :OperationalSequences,
      "super_diff/active_support/operational_sequences",
    )

    SuperDiff.configure do |config|
      config.add_extra_differ_classes(
        Differs::HashWithIndifferentAccess,
      )
      config.add_extra_operation_tree_builder_classes(
        OperationTreeBuilders::HashWithIndifferentAccess,
      )
      config.add_extra_diff_formatter_classes(
        DiffFormatters::HashWithIndifferentAccess,
      )
      config.add_extra_inspector_classes(
        ObjectInspection::Inspectors::HashWithIndifferentAccess,
      )
    end
  end
end
