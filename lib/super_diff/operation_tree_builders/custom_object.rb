module SuperDiff
  module OperationTreeBuilders
    class CustomObject < DefaultObject
      def self.applies_to?(expected, actual)
        expected.class == actual.class &&
          expected.respond_to?(:attributes_for_super_diff) &&
          actual.respond_to?(:attributes_for_super_diff)
      end

      protected

      def build_operation_tree
        # NOTE: It doesn't matter whether we use expected or actual here,
        # because all we care about is the name of the class
        OperationTrees::CustomObject.new([], underlying_object: actual)
      end

      def attribute_names
        expected.attributes_for_super_diff.keys &
          actual.attributes_for_super_diff.keys
      end

      private

      attr_reader :expected_attributes, :actual_attributes

      def establish_expected_and_actual_attributes
        @expected_attributes = attribute_names.reduce({}) do |hash, name|
          hash.merge(name => expected.public_send(name))
        end

        @actual_attributes = attribute_names.reduce({}) do |hash, name|
          hash.merge(name => actual.public_send(name))
        end
      end
    end
  end
end
