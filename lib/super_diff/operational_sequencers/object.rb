module SuperDiff
  module OperationalSequencers
    class Object < Base
      def initialize(*args)
        super(*args)

        @expected_attributes = attribute_names.inject({}) do |hash, name|
          hash.merge(name => expected.public_send(name))
        end

        @actual_attributes = attribute_names.inject({}) do |hash, name|
          hash.merge(name => actual.public_send(name))
        end
      end

      protected

      def unary_operations
        attribute_names.inject([]) do |operations, name|
          if (
            expected_attributes.include?(name) &&
            actual_attributes.include?(name) &&
            expected_attributes[name] == actual_attributes[name]
          )
            operations << Operations::UnaryOperation.new(
              name: :noop,
              collection: actual_attributes,
              key: name,
              index: attribute_names.index(name),
              value: actual_attributes[name]
            )
          end

          if (
            expected_attributes.include?(name) &&
            (
              !actual_attributes.include?(name) ||
              expected_attributes[name] != actual_attributes[name]
            )
          )
            operations << Operations::UnaryOperation.new(
              name: :delete,
              collection: expected_attributes,
              key: name,
              index: attribute_names.index(name),
              value: expected_attributes[name]
            )
          end

          if (
            !expected_attributes.include?(name) ||
            (
              actual_attributes.include?(name) &&
              expected_attributes[name] != actual_attributes[name]
            )
          )
            operations << Operations::UnaryOperation.new(
              name: :insert,
              collection: actual_attributes,
              key: name,
              index: attribute_names.index(name),
              value: actual_attributes[name]
            )
          end

          operations
        end
      end

      def operation_sequence_class
        OperationSequences::Object
      end

      def attribute_names
        raise NotImplementedError
      end

      private

      attr_reader :expected_attributes, :actual_attributes
    end
  end
end
