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

    SuperDiff.configure do |config|
      config.add_extra_differ_classes(
        Differs::HashWithIndifferentAccess,
      )
      config.add_extra_operational_sequencer_classes(
        OperationalSequencers::HashWithIndifferentAccess,
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
