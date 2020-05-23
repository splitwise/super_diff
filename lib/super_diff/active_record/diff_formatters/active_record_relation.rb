module SuperDiff
  module ActiveRecord
    module DiffFormatters
      class ActiveRecordRelation < SuperDiff::DiffFormatters::Base
        def self.applies_to?(operation_tree)
          operation_tree.is_a?(OperationTrees::ActiveRecordRelation)
        end

        def call
          SuperDiff::DiffFormatters::Collection.call(
            open_token: "#<ActiveRecord::Relation [",
            close_token: "]>",
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
end
