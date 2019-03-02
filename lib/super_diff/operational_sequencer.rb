module SuperDiff
  class OperationalSequencer
    def self.call(*args)
      new(*args).call
    end

    def initialize(
      expected:,
      actual:,
      extra_classes: [],
      extra_diff_formatter_classes: []
    )
      @expected = expected
      @actual = actual
      @extra_classes = extra_classes
      @extra_diff_formatter_classes = extra_diff_formatter_classes
    end

    def call
      if resolved_class
        resolved_class.call(
          expected: expected,
          actual: actual,
          extra_operational_sequencer_classes: extra_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes,
        )
      else
        raise NoOperationalSequencerAvailableError.create(expected, actual)
      end
    end

    private

    attr_reader :expected, :actual, :extra_classes,
      :extra_diff_formatter_classes

    def resolved_class
      (extra_classes + OperationalSequencers::DEFAULTS).find do |klass|
        klass.applies_to?(expected, actual)
      end
    end
  end
end
