module SuperDiff
  module OperationalSequencers
    class Base
      def self.applies_to?(_value)
        raise NotImplementedError
      end

      def self.call(*args)
        new(*args).call
      end

      def initialize(
        expected:,
        actual:,
        extra_operational_sequencer_classes: [],
        extra_diff_formatter_classes: []
      )
        @expected = expected
        @actual = actual
        @extra_operational_sequencer_classes =
          extra_operational_sequencer_classes
        @extra_diff_formatter_classes = extra_diff_formatter_classes
      end

      def call
        i = 0
        operations = operation_sequence_class.new([])

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

      def operation_sequence_class
        raise NotImplementedError
      end

      private

      attr_reader :expected, :actual, :extra_operational_sequencer_classes,
        :extra_diff_formatter_classes

      def possible_comparison_of(operation, next_operation)
        if should_compare?(operation, next_operation)
          sequence(operation, next_operation)
        end
      end

      def should_compare?(operation, next_operation)
        next_operation &&
          operation.name == :delete &&
          next_operation.name == :insert &&
          next_operation.index == operation.index
      end

      def sequence(operation, next_operation)
        OperationalSequencer.call(
          expected: operation.value,
          actual: next_operation.value,
          extra_classes: extra_operational_sequencer_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes,
        )
      rescue NoOperationalSequencerAvailableError
        nil
      end
    end
  end
end
