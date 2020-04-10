module SuperDiff
  module Differs
    class DefaultObject < Base
      def self.applies_to?(expected, actual)
        expected.class == actual.class
      end

      private

      def operations
        OperationalSequencer.call(
          expected: expected,
          actual: actual,
          all_or_nothing: true,
          extra_operation_sequence_classes: extra_operation_sequence_classes,
          extra_classes: extra_operational_sequencer_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes,
        )
      end
    end
  end
end
