module SuperDiff
  module Differs
    class CustomObject < Base
      def self.applies_to?(expected, actual)
        expected.class == actual.class &&
          expected.respond_to?(:attributes_for_super_diff) &&
          actual.respond_to?(:attributes_for_super_diff)
      end

      def call
        operations.to_diff(indent_level: indent_level)
      end

      private

      def operations
        OperationalSequencers::CustomObject.call(
          expected: expected,
          actual: actual,
          extra_operational_sequencer_classes: extra_operational_sequencer_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes,
        )
      end
    end
  end
end
