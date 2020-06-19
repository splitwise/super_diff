module SuperDiff
  module Differs
    class Hash < Base
      def self.applies_to?(expected, actual)
        expected.is_a?(::Hash) && actual.is_a?(::Hash)
      end

      protected

      def operation_tree_builder_class
        OperationTreeBuilders::Hash
      end
    end
  end
end
