module SuperDiff
  module OperationSequences
    class MultilineString < Base
      def self.applies_to?(value)
        value.is_a?(::String) && value.is_a?(::String)
      end

      def to_diff(indent_level:, collection_prefix:, add_comma:)
        DiffFormatters::MultilineString.call(
          self,
          indent_level: indent_level,
          collection_prefix: collection_prefix,
          add_comma: add_comma,
        )
      end
    end
  end
end
