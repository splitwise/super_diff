module SuperDiff
  module Differs
    class Array < Base
      def self.applies_to?(expected, actual)
        expected.is_a?(::Array) && actual.is_a?(::Array)
      end

      protected

      def operation_tree_builder_class
        OperationTreeBuilders::Array
      end
    end
  end
end
