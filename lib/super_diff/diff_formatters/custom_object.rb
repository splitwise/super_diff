module SuperDiff
  module DiffFormatters
    class CustomObject < DefaultObject
      def self.applies_to?(operations)
        operations.is_a?(OperationSequences::CustomObject)
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

            "#{key}: "
          },
          operations: operations,
          indent_level: indent_level,
          add_comma: add_comma?,
        )
      end
    end
  end
end
