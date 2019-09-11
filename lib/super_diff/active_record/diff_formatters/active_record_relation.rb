module SuperDiff
  module ActiveRecord
    module DiffFormatters
      class ActiveRecordRelation < SuperDiff::DiffFormatters::Base
        def self.applies_to?(operations)
          operations.is_a?(OperationSequences::ActiveRecordRelation)
        end

        def call
          SuperDiff::DiffFormatters::Collection.call(
            open_token: "#<ActiveRecord::Relation [",
            close_token: "]>",
            collection_prefix: collection_prefix,
            build_item_prefix: proc { "" },
            operations: operations,
            indent_level: indent_level,
            add_comma: add_comma?,
          )
        end
      end
    end
  end
end
