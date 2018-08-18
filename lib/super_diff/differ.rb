module SuperDiff
  class Differ
    def self.call(*args)
      new(*args).call
    end

    def initialize(
      expected,
      actual,
      indent_level:,
      index_in_collection: nil,
      extra_classes: [],
      extra_operational_sequencer_classes: [],
      extra_diff_formatter_classes: []
    )
      @expected = expected
      @actual = actual
      @indent_level = indent_level
      @index_in_collection = index_in_collection
      @extra_classes = extra_classes
      @extra_operational_sequencer_classes = extra_operational_sequencer_classes
      @extra_diff_formatter_classes = extra_diff_formatter_classes
    end

    def call
      resolved_class.call(
        expected,
        actual,
        indent_level: indent_level,
        index_in_collection: index_in_collection,
        extra_operational_sequencer_classes: extra_operational_sequencer_classes,
        extra_diff_formatter_classes: extra_diff_formatter_classes
      )
    end

    private

    def resolved_class
      (Differs::DEFAULTS + extra_classes).detect do |klass|
        klass.applies_to?(expected) && klass.applies_to?(actual)
      end
    end
  end
end
