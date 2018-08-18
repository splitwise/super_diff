module SuperDiff
  module OperationalSequencers
    class Base
      def self.applies_to?(value)
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

          if (
            next_operation &&
            operation.name == :delete &&
            next_operation.name == :insert &&
            next_operation.index == operation.index &&
            child_operations = sequence(operation, next_operation)
          )
            operations << BinaryOperation.new(
              name: :change,
              left_collection: operation.collection,
              left_value: operation.collection[operation.key],
              right_collection: next_operation.collection,
              right_value: next_operation.collection[operation.key],
              key: operation.key,
              index: operation.index,
              child_operations: child_operations
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

      def sequence(operation, next_operation)
        OperationalSequencer.call(
          expected: operation.value,
          actual: next_operation.value,
          extra_classes: extra_operational_sequencer_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes
        )
      rescue NoOperationalSequencerAvailableError
        nil
      end

      class UnaryOperation
        attr_reader(
          :name,
          :collection,
          :key,
          :value,
          :index
        )

        def initialize(name:, collection:, key:, value:, index:)
          @name = name
          @collection = collection
          @key = key
          @value = value
          @index = index
        end
      end

      class BinaryOperation
        attr_reader(
          :name,
          :left_collection,
          :right_collection,
          :key,
          :left_value,
          :right_value,
          :index,
          :child_operations
        )

        def initialize(
          name:,
          left_collection:,
          left_value:,
          right_collection:,
          right_value:,
          key:,
          index:,
          child_operations:
        )
          @name = name
          @left_collection = left_collection
          @left_value = left_value
          @right_collection = right_collection
          @right_value = right_value
          @key = key
          @index = index
          @child_operations = child_operations
        end
      end
    end
  end
end
