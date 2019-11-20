module SuperDiff
  module Differs
    class Time < Base
      def self.applies_to?(expected, actual)
        OperationalSequencers::TimeLike.applies_to?(expected, actual)
      end

      def call
        operations.to_diff(indent_level: indent_level)
      end

      private

      def operations
        OperationalSequencers::TimeLike.call(
          expected: expected,
          actual: actual,
          extra_operational_sequencer_classes: extra_operational_sequencer_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes,
        )
      end
    end
  end
end
