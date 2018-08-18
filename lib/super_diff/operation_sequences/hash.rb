module SuperDiff
  module OperationSequences
    class Hash < Base
      def to_diff(indent_level:, collection_prefix:, add_comma:)
        DiffFormatters::Hash.call(
          self,
          indent_level: indent_level,
          collection_prefix: collection_prefix,
          add_comma: add_comma
        )
      end
    end
  end
end
