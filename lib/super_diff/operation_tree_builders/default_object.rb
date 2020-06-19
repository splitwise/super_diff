module SuperDiff
  module OperationTreeBuilders
    class DefaultObject < Base
      def self.applies_to?(_expected, _actual)
        true
      end

      def initialize(*args)
        super(*args)

        establish_expected_and_actual_attributes
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

      def build_operation_tree
        # XXX This assumes that `expected` and `actual` are the same
        # TODO: Does this need to be find_operation_tree_for?
        OperationTrees::DefaultObject.new([], underlying_object: actual)
      end

      def find_operation_tree_for(value)
        OperationTrees::Main.call(value)
      end

      def attribute_names
        (expected.instance_variables.sort & actual.instance_variables.sort).
          map { |variable_name| variable_name[1..-1] }
      end

      private

      attr_reader :expected_attributes, :actual_attributes

      def establish_expected_and_actual_attributes
        @expected_attributes = attribute_names.reduce({}) do |hash, name|
          hash.merge(name => expected.instance_variable_get("@#{name}"))
        end

        @actual_attributes = attribute_names.reduce({}) do |hash, name|
          hash.merge(name => actual.instance_variable_get("@#{name}"))
        end
      end

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
