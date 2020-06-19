module SuperDiff
  module Differs
    class Base
      def self.applies_to?(_expected, _actual)
        raise NotImplementedError
      end

      extend ImplementationChecks
      extend AttrExtras.mixin
      include ImplementationChecks

      method_object :expected, :actual, [:indent_level!]

      def call
        operation_tree.to_diff(indentation_level: indent_level)
      end

      protected

      def operation_tree_builder_class
        unimplemented_instance_method!
      end

      private

      def operation_tree
        operation_tree_builder_class.call(expected: expected, actual: actual)
      end
    end
  end
end
