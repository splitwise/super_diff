module SuperDiff
  module OperationTrees
    class CustomObject < DefaultObject
      def self.applies_to?(value)
        value.respond_to?(:attributes_for_super_diff)
      end

      protected

      def operation_tree_flattener_class
        OperationTreeFlatteners::CustomObject
      end
    end
  end
end
