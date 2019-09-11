module SuperDiff
  module ActiveRecord
    autoload(
      :ObjectInspection,
      "super_diff/active_record/object_inspection",
    )
    autoload(
      :OperationalSequencer,
      "super_diff/active_record/operational_sequencer",
    )
  end
end

if defined?(SuperDiff::RSpec)
  SuperDiff::RSpec.configuration.add_extra_operational_sequencer_class(
    SuperDiff::ActiveRecord::OperationalSequencer,
  )
end

SuperDiff::ObjectInspection.map.prepend(
  SuperDiff::ActiveRecord::ObjectInspection::MapExtension,
)
