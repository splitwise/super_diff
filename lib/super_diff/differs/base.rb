module SuperDiff
  module Differs
    class Base
      def self.applies_to?(_expected, _actual)
        raise NotImplementedError
      end

      extend ImplementationChecks
      extend AttrExtras.mixin
      include ImplementationChecks

      method_object(
        :expected,
        :actual,
        [
          :indent_level!,
          index_in_collection: nil,
          extra_operation_sequence_classes: [],
          extra_operational_sequencer_classes: [],
          extra_diff_formatter_classes: [],
        ],
      )

      def call
        operations.to_diff(
          indent_level: indent_level,
          collection_prefix: nil,
          add_comma: false,
        )
      end

      protected

      def indentation
        " " * (indent_level * 2)
      end

      def operational_sequencer_class
        unimplemented_instance_method!
      end

      private

      def operations
        operational_sequencer_class.call(
          expected: expected,
          actual: actual,
          extra_operation_sequence_classes: extra_operation_sequence_classes,
          extra_operational_sequencer_classes: extra_operational_sequencer_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes,
        )
      end
    end
  end
end
