module SuperDiff
  module ActiveSupport
    autoload :DiffFormatters, "super_diff/active_support/diff_formatters"
    autoload :Differs, "super_diff/active_support/differs"
    autoload :ObjectInspection, "super_diff/active_support/object_inspection"
    autoload(
      :OperationalSequencers,
      "super_diff/active_support/operational_sequencers",
    )
    autoload(
      :OperationalSequences,
      "super_diff/active_support/operational_sequences",
    )
  end
end

if defined?(SuperDiff::RSpec)
  SuperDiff::RSpec.configure do |config|
    config.add_extra_differ_class(
      SuperDiff::ActiveSupport::Differs::HashWithIndifferentAccess,
    )
    config.add_extra_operational_sequencer_class(
      SuperDiff::ActiveSupport::OperationalSequencers::HashWithIndifferentAccess,
    )
    config.add_extra_diff_formatter_class(
      SuperDiff::ActiveSupport::DiffFormatters::HashWithIndifferentAccess,
    )
  end
end

SuperDiff::ObjectInspection.map.prepend(
  SuperDiff::ActiveSupport::ObjectInspection::MapExtension,
)
