module SuperDiff
  module Differs
    class DefaultObject < Base
      def self.applies_to?(_expected, _actual)
        true
      end

      def call
        operations.to_diff(indent_level: indent_level)
      end

      private

      def operations
        OperationalSequencer.call(
          expected: expected,
          actual: actual,
          all_or_nothing: true,
          extra_classes: extra_operational_sequencer_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes,
        )
      end
    end
  end
end
