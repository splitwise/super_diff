module SuperDiff
  module Differs
    class Array < Base
      def self.applies_to?(expected, actual)
        expected.is_a?(::Array) && actual.is_a?(::Array)
      end

      def call
        DiffFormatters::Array.call(operations, indent_level: indent_level)
      end

      private

      def operations
        OperationalSequencers::Array.call(
          expected: expected,
          actual: actual,
          extra_operational_sequencer_classes: extra_operational_sequencer_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes,
        )
      end
    end
  end
end
