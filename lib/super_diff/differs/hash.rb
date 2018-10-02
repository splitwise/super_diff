module SuperDiff
  module Differs
    class Hash < Base
      def self.applies_to?(value)
        value.is_a?(::Hash)
      end

      def call
        DiffFormatters::Hash.call(operations, indent_level: indent_level)
      end

      private

      def operations
        OperationalSequencers::Hash.call(
          expected: expected,
          actual: actual,
          extra_operational_sequencer_classes: extra_operational_sequencer_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes,
        )
      end
    end
  end
end
