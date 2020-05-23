module SuperDiff
  module ActiveRecord
    module OperationTrees
      class ActiveRecordRelation < SuperDiff::OperationTrees::Array
        def to_diff(indent_level:, collection_prefix:, add_comma:)
          DiffFormatters::ActiveRecordRelation.call(
            self,
            indent_level: indent_level,
            collection_prefix: collection_prefix,
            add_comma: add_comma,
          )
        end
      end
    end
  end
end
