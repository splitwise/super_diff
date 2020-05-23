module SuperDiff
  module DiffFormatters
    class Array < Base
      def self.applies_to?(operation_tree)
        operation_tree.is_a?(OperationTrees::Array)
      end

      def call
        Collection.call(
          open_token: "[",
          close_token: "]",
          collection_prefix: collection_prefix,
          build_item_prefix: proc { "" },
          operation_tree: operation_tree,
          indent_level: indent_level,
          add_comma: add_comma?,
        )
      end
    end
  end
end
