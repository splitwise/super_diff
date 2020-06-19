module SuperDiff
  module OperationTrees
    class Hash < Base
      def self.applies_to?(value)
        value.is_a?(::Hash)
      end

      protected

      def operation_tree_flattener_class
        OperationTreeFlatteners::Hash
      end
    end
  end
end
