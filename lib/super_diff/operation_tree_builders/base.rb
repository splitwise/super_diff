module SuperDiff
  module OperationTreeBuilders
    class Base
      def self.applies_to?(_expected, _actual)
        raise NotImplementedError
      end

      extend AttrExtras.mixin
      include ImplementationChecks

      method_object [:expected!, :actual!]

      def call
        operation_tree
      end

      protected

      def unary_operations
        unimplemented_instance_method!
      end

      def build_operation_tree
        unimplemented_instance_method!
      end

      private

      def operation_tree
        unary_operations = self.unary_operations
        operation_tree = build_operation_tree
        unmatched_delete_operations = []

        unary_operations.each_with_index do |operation, index|
          if (
            operation.name == :insert &&
            (delete_operation = unmatched_delete_operations.find { |op| op.key == operation.key }) &&
            (insert_operation = operation)
          )
            unmatched_delete_operations.delete(delete_operation)

            if (children = possible_comparison_of(
              delete_operation,
              insert_operation,
            ))
              operation_tree.delete(delete_operation)
              operation_tree << Operations::BinaryOperation.new(
                name: :change,
                left_collection: delete_operation.collection,
                right_collection: insert_operation.collection,
                left_key: delete_operation.key,
                right_key: insert_operation.key,
                left_value: delete_operation.collection[operation.key],
                right_value: insert_operation.collection[operation.key],
                left_index: delete_operation.index,
                right_index: insert_operation.index,
                children: children,
              )
            else
              operation_tree << insert_operation
            end
          else
            if operation.name == :delete
              unmatched_delete_operations << operation
            end

            operation_tree << operation
          end
        end

        operation_tree
      end

      def possible_comparison_of(operation, next_operation)
        if should_compare?(operation, next_operation)
          compare(operation.value, next_operation.value)
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

      def compare(expected, actual)
        OperationTreeBuilders::Main.call(
          expected: expected,
          actual: actual,
          all_or_nothing: false,
        )
      end
    end
  end
end
