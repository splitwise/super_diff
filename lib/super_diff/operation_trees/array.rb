module SuperDiff
  module OperationTrees
    class Array < Base
      def self.applies_to?(value)
        value.is_a?(::Array)
      end

      protected

      def operation_tree_flattener_class
        OperationTreeFlatteners::Array
      end
    end
  end
end
