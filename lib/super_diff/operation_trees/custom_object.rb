module SuperDiff
  module OperationTrees
    class CustomObject < DefaultObject
      def self.applies_to?(value)
        value.respond_to?(:attributes_for_super_diff)
      end

      def to_diff(indent_level:, add_comma: false, collection_prefix: nil)
        DiffFormatters::CustomObject.call(
          self,
          indent_level: indent_level,
          collection_prefix: collection_prefix,
          add_comma: add_comma,
          value_class: value_class,
        )
      end
    end
  end
end
