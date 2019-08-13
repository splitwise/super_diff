module SuperDiff
  module Differs
    class Object < Base
      def self.applies_to?(expected, actual)
        expected.is_a?(::Object) && actual.is_a?(::Object)
      end

      def call
        operations.to_diff(indent_level: indent_level)
      end

      private

      def operations
        OperationalSequencers::Object.call(
          expected: expected,
          actual: actual,
          extra_operational_sequencer_classes: extra_operational_sequencer_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes,
        )
      end
    end
  end
end
