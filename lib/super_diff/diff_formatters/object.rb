module SuperDiff
  module DiffFormatters
    class Object < Base
      def self.applies_to?(operations)
        operations.is_a?(OperationSequences::Object)
      end

      def call
        Collection.call(
          open_token: "#<#{value_class} {",
          close_token: "}>",
          collection_prefix: collection_prefix,
          build_item_prefix: -> (operation) { "#{operation.key}: " },
          operations: operations,
          indent_level: indent_level,
          add_comma: add_comma?,
        )
      end

      protected

      def value_class
        raise NotImplementedError
      end
    end
  end
end
