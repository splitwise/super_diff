module SuperDiff
  module DiffFormatters
    class DefaultObject < Base
      def self.applies_to?(operation_tree)
        operation_tree.is_a?(OperationTrees::DefaultObject)
      end

      def initialize(operation_tree, value_class: nil, **rest)
        super(operation_tree, **rest)

        @value_class = value_class
      end

      def call
        Collection.call(
          open_token: "#<#{value_class} {",
          close_token: "}>",
          collection_prefix: collection_prefix,
          build_item_prefix: -> (operation) {
            key =
              if operation.respond_to?(:left_key)
                operation.left_key
              else
                operation.key
              end

            "@#{key}="
          },
          operation_tree: operation_tree,
          indent_level: indent_level,
          add_comma: add_comma?,
        )
      end

      protected

      def value_class
        if @value_class
          @value_class
        else
          unimplemented_instance_method!
        end
      end
    end
  end
end
