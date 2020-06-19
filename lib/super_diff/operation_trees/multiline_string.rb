module SuperDiff
  module OperationTrees
    class MultilineString < Base
      def self.applies_to?(value)
        value.is_a?(::String) && value.is_a?(::String)
      end

      protected

      def operation_tree_flattener_class
        OperationTreeFlatteners::MultilineString
      end
    end
  end
end
