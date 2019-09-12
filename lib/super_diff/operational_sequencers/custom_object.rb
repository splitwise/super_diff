module SuperDiff
  module OperationalSequencers
    class CustomObject < DefaultObject
      def self.applies_to?(expected, actual)
        expected.respond_to?(:attributes_for_super_diff) &&
          actual.respond_to?(:attributes_for_super_diff)
      end

      def build_operation_sequencer
        # XXX This assumes that `expected` and `actual` are the same
        OperationSequences::CustomObject.new([], value_class: expected.class)
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
