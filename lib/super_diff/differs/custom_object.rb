module SuperDiff
  module Differs
    class CustomObject < Base
      def self.applies_to?(expected, actual)
        expected.class == actual.class &&
          expected.respond_to?(:attributes_for_super_diff) &&
          actual.respond_to?(:attributes_for_super_diff)
      end

      protected

      def operation_tree_builder_class
        OperationTreeBuilders::CustomObject
      end
    end
  end
end
