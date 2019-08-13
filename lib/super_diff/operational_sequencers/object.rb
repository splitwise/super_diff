module SuperDiff
  module OperationalSequencers
    class Object < Base
      def initialize(*args)
        super(*args)

        @expected_attributes = attribute_names.reduce({}) do |hash, name|
          hash.merge(name => read_attribute_from(expected, name))
        end

        @actual_attributes = attribute_names.reduce({}) do |hash, name|
          hash.merge(name => read_attribute_from(actual, name))
        end
      end

      protected

      def unary_operations
        attribute_names.reduce([]) do |operations, name|
          possibly_add_noop_operation_to(operations, name)
          possibly_add_delete_operation_to(operations, name)
          possibly_add_insert_operation_to(operations, name)
          operations
        end
      end

      def build_operation_sequencer
        # XXX This assumes that `expected` and `actual` are the same
        OperationSequences::Object.new([], value_class: expected.class)
      end

      def attribute_names
        (expected.instance_variables & actual.instance_variables).
          map { |variable_name| variable_name[1..-1] }
      end

      def read_attribute_from(value, attribute_name)
        value.instance_variable_get("@#{attribute_name}")
      end

      private

      attr_reader :expected_attributes, :actual_attributes

      def possibly_add_noop_operation_to(operations, attribute_name)
        if should_add_noop_operation?(attribute_name)
          operations << Operations::UnaryOperation.new(
            name: :noop,
            collection: actual_attributes,
            key: attribute_name,
            index: attribute_names.index(attribute_name),
            value: actual_attributes[attribute_name],
          )
        end
      end

      def should_add_noop_operation?(attribute_name)
        expected_attributes.include?(attribute_name) &&
          actual_attributes.include?(attribute_name) &&
          expected_attributes[attribute_name] == actual_attributes[attribute_name]
      end

      def possibly_add_delete_operation_to(operations, attribute_name)
        if should_add_delete_operation?(attribute_name)
          operations << Operations::UnaryOperation.new(
            name: :delete,
            collection: expected_attributes,
            key: attribute_name,
            index: attribute_names.index(attribute_name),
            value: expected_attributes[attribute_name],
          )
        end
      end

      def should_add_delete_operation?(attribute_name)
        expected_attributes.include?(attribute_name) && (
          !actual_attributes.include?(attribute_name) ||
          expected_attributes[attribute_name] != actual_attributes[attribute_name]
        )
      end

      def possibly_add_insert_operation_to(operations, attribute_name)
        if should_add_insert_operation?(attribute_name)
          operations << Operations::UnaryOperation.new(
            name: :insert,
            collection: actual_attributes,
            key: attribute_name,
            index: attribute_names.index(attribute_name),
            value: actual_attributes[attribute_name],
          )
        end
      end

      def should_add_insert_operation?(attribute_name)
        !expected_attributes.include?(attribute_name) || (
          actual_attributes.include?(attribute_name) &&
          expected_attributes[attribute_name] != actual_attributes[attribute_name]
        )
      end
    end
  end
end
