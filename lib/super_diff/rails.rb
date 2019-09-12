module SuperDiff
  module Rails
    autoload :DiffFormatters, "super_diff/rails/diff_formatters"
    autoload :Differs, "super_diff/rails/differs"
    autoload :ObjectInspection, "super_diff/rails/object_inspection"
    autoload :OperationalSequencers, "super_diff/rails/operational_sequencers"
    autoload :OperationalSequences, "super_diff/rails/operational_sequences"
  end
end

if defined?(SuperDiff::RSpec)
  SuperDiff::RSpec.configure do |config|
    config.add_extra_differ_class(
      SuperDiff::Rails::Differs::HashWithIndifferentAccess,
    )
    config.add_extra_operational_sequencer_class(
      SuperDiff::Rails::OperationalSequencers::HashWithIndifferentAccess,
    )
    config.add_extra_diff_formatter_class(
      SuperDiff::Rails::DiffFormatters::HashWithIndifferentAccess,
    )
  end
end

SuperDiff::ObjectInspection.map.prepend(
  SuperDiff::Rails::ObjectInspection::MapExtension,
)

require "super_diff/active_record"
