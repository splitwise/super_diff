module SuperDiff
  class Differ
    extend AttrExtras.mixin

    method_object(
      :expected,
      :actual,
      [
        indent_level: 0,
        index_in_collection: nil,
        extra_classes: [],
        extra_operational_sequencer_classes: [],
        extra_diff_formatter_classes: [],
      ],
    )

    def call
      resolved_class.call(
        expected,
        actual,
        indent_level: indent_level,
        index_in_collection: index_in_collection,
        extra_operational_sequencer_classes: extra_operational_sequencer_classes,
        extra_diff_formatter_classes: extra_diff_formatter_classes,
      )
    end

    private

    def resolved_class
      (extra_classes + Differs::DEFAULTS).find do |klass|
        klass.applies_to?(expected, actual)
      end
    end
  end
end
