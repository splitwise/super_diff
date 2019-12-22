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
  end
end

if defined?(SuperDiff::RSpec)
  SuperDiff::RSpec.configure do |config|
    config.add_extra_differ_class(
      SuperDiff::ActiveRecord::Differs::ActiveRecordRelation,
    )
    config.add_extra_operational_sequencer_class(
      SuperDiff::ActiveRecord::OperationalSequencers::ActiveRecordModel,
    )
    config.add_extra_operational_sequencer_class(
      SuperDiff::ActiveRecord::OperationalSequencers::ActiveRecordRelation,
    )
    config.add_extra_diff_formatter_class(
      SuperDiff::ActiveRecord::DiffFormatters::ActiveRecordRelation,
    )
  end
end

require "super_diff/active_record/monkey_patches"

SuperDiff::ObjectInspection.map.prepend(
  SuperDiff::ActiveRecord::ObjectInspection::MapExtension,
)
