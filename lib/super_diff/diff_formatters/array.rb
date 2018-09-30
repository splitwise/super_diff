module SuperDiff
  module DiffFormatters
    class Array < Base
      def self.applies_to?(operations)
        operations.is_a?(OperationSequences::Array)
      end

      def call
        Collection.call(
          open_token: "[",
          close_token: "]",
          collection_prefix: collection_prefix,
          build_item_prefix: -> (operation) { "" },
          operations: operations,
          indent_level: indent_level,
          add_comma: add_comma?
        )
      end
    end
  end
end
