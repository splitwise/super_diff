module SuperDiff
  class Differ
    def self.call(*args)
      new(*args).call
    end

    def initialize(
      expected,
      actual,
      indent_level: 0,
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
      if Helpers.values_equal?(expected, actual)
        ""
      else
        diff
      end
    end

    private

    attr_reader :expected, :actual, :indent_level, :index_in_collection,
      :extra_classes, :extra_operational_sequencer_classes,
      :extra_diff_formatter_classes

    def diff
      resolved_class.call(
        expected,
        actual,
        indent_level: indent_level,
        index_in_collection: index_in_collection,
        extra_operational_sequencer_classes: extra_operational_sequencer_classes,
        extra_diff_formatter_classes: extra_diff_formatter_classes,
      )
    end

    def resolved_class
      (extra_classes + Differs::DEFAULTS).find do |klass|
        klass.applies_to?(expected) && klass.applies_to?(actual)
      end
    end
  end
end
