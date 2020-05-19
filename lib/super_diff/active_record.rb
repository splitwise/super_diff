require "super_diff/active_support"

module SuperDiff
  module ActiveRecord
    autoload :DiffFormatters, "super_diff/active_record/diff_formatters"
    autoload :Differs, "super_diff/active_record/differs"
    autoload(
      :ObjectInspection,
      "super_diff/active_record/object_inspection",
    )
    autoload(
      :OperationSequences,
      "super_diff/active_record/operation_sequences",
    )
    autoload(
      :OperationalSequencers,
      "super_diff/active_record/operational_sequencers",
    )

    SuperDiff.configure do |config|
      config.add_extra_differ_classes(
        Differs::ActiveRecordRelation,
      )
      config.add_extra_operational_sequencer_classes(
        OperationalSequencers::ActiveRecordModel,
        OperationalSequencers::ActiveRecordRelation,
      )
      config.add_extra_diff_formatter_classes(
        DiffFormatters::ActiveRecordRelation,
      )
      config.add_extra_inspector_classes(
        ObjectInspection::Inspectors::ActiveRecordModel,
        ObjectInspection::Inspectors::ActiveRecordRelation,
      )
    end
  end
end

require "super_diff/active_record/monkey_patches"
