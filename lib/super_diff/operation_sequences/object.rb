module SuperDiff
  module OperationSequences
    class Object < Base
      def initialize(collection, value_class:)
        super(collection)

        @value_class = value_class
      end

      def to_diff(indent_level:, add_comma: false, collection_prefix: nil)
        DiffFormatters::Object.call(
          self,
          indent_level: indent_level,
          collection_prefix: collection_prefix,
          add_comma: add_comma,
          value_class: value_class,
        )
      end

      private

      attr_reader :value_class
    end
  end
end
