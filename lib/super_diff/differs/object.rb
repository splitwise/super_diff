module SuperDiff
  module Differs
    class Object < Base
      def self.applies_to?(value)
        value.is_a?(::Object)
      end

      def call
        operations.to_diff(indent_level: indent_level)
      end

      private

      def operations
        OperationalSequencer.call(
          expected: expected,
          actual: actual,
          extra_classes: extra_operational_sequencer_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes,
        )
      end
    end
  end
end
