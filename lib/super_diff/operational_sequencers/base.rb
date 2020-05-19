module SuperDiff
  module OperationalSequencers
    class Base
      def self.applies_to?(_expected, _actual)
        raise NotImplementedError
      end

      extend AttrExtras.mixin
      include ImplementationChecks

      method_object [:expected!, :actual!]

      def call
        compressed_operations
      end

      protected

      def unary_operations
        unimplemented_instance_method!
      end

      def build_operation_sequence
        unimplemented_instance_method!
      end

      private

      def compressed_operations
        unary_operations = self.unary_operations
        compressed_operations = build_operation_sequence
        unmatched_delete_operations = []

        unary_operations.each_with_index do |operation, index|
          if (
            operation.name == :insert &&
            (delete_operation = unmatched_delete_operations.find { |op| op.key == operation.key }) &&
            (insert_operation = operation)
          )
            unmatched_delete_operations.delete(delete_operation)

            if (child_operations = possible_comparison_of(
              delete_operation,
              insert_operation,
            ))
              compressed_operations.delete(delete_operation)
              compressed_operations << Operations::BinaryOperation.new(
                name: :change,
                left_collection: delete_operation.collection,
                right_collection: insert_operation.collection,
                left_key: delete_operation.key,
                right_key: insert_operation.key,
                left_value: delete_operation.collection[operation.key],
                right_value: insert_operation.collection[operation.key],
                left_index: delete_operation.index_in_collection,
                right_index: insert_operation.index_in_collection,
                child_operations: child_operations,
              )
            else
              compressed_operations << insert_operation
            end
          else
            if operation.name == :delete
              unmatched_delete_operations << operation
            end

            compressed_operations << operation
          end
        end

        compressed_operations
      end

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
          next_operation.key == operation.key
      end

      def sequence(expected, actual)
        OperationalSequencers::Main.call(
          expected: expected,
          actual: actual,
          all_or_nothing: false,
        )
      end
    end
  end
end
