module SuperDiff
  class EqualityMatcher
    def self.call(*args)
      new(*args).call
    end

    def initialize(
      expected:,
      actual:,
      extra_classes: [],
      extra_operational_sequencer_classes: [],
      extra_diff_formatter_classes: []
    )
      @expected = expected
      @actual = actual
      @extra_classes = extra_classes
      @extra_operational_sequencer_classes = extra_operational_sequencer_classes
      @extra_diff_formatter_classes = extra_diff_formatter_classes
    end

    def call
      resolved_class.call(
        expected: expected,
        actual: actual,
        extra_operational_sequencer_classes: extra_operational_sequencer_classes,
        extra_diff_formatter_classes: extra_diff_formatter_classes,
      )
    end

    private

    attr_reader :expected, :actual, :extra_classes,
      :extra_operational_sequencer_classes, :extra_diff_formatter_classes

    def resolved_class
      matching_class || EqualityMatchers::Object
    end

    def matching_class
      (EqualityMatchers::DEFAULTS + extra_classes).find do |klass|
        klass.applies_to?(expected) && klass.applies_to?(actual)
      end
    end
  end
end
