module SuperDiff
  module OperationalSequencers
    class Base
      def self.applies_to?(_expected, _actual)
        raise NotImplementedError
      end

      extend AttrExtras.mixin

      method_object(
        [
          :expected!,
          :actual!,
          extra_operational_sequencer_classes: [],
          extra_diff_formatter_classes: [],
        ],
      )

      def call
        i = 0
        operations = build_operation_sequencer

        while i < unary_operations.length
          operation = unary_operations[i]
          next_operation = unary_operations[i + 1]
          child_operations = possible_comparison_of(operation, next_operation)

          if child_operations
            operations << Operations::BinaryOperation.new(
              name: :change,
              left_collection: operation.collection,
              right_collection: next_operation.collection,
              left_key: operation.key,
              right_key: operation.key,
              left_value: operation.collection[operation.key],
              right_value: next_operation.collection[operation.key],
              left_index: operation.index,
              right_index: operation.index,
              child_operations: child_operations,
            )
            i += 2
          else
            operations << operation
            i += 1
          end
        end

        operations
      end

      protected

      def unary_operations
        raise NotImplementedError
      end

      def build_operation_sequencer
        raise NotImplementedError
      end

      private

      def possible_comparison_of(operation, next_operation)
        if should_compare?(operation, next_operation)
          sequence(operation.value, next_operation.value)
        else
          nil
        end
      end

      def should_compare?(operation, next_operation)
        next_operation &&
          operation.name == :delete &&
          next_operation.name == :insert &&
          next_operation.index == operation.index
      end

      def sequence(expected, actual)
        OperationalSequencer.call(
          expected: expected,
          actual: actual,
          all_or_nothing: false,
          extra_classes: extra_operational_sequencer_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes,
        )
      end
    end
  end
end
