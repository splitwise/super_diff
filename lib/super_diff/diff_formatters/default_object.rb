module SuperDiff
  module DiffFormatters
    class DefaultObject < Base
      def self.applies_to?(operations)
        operations.is_a?(OperationSequences::DefaultObject)
      end

      def initialize(operations, value_class: nil, **rest)
        super(operations, **rest)

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
          operations: operations,
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
