module SuperDiff
  module OperationSequences
    class DefaultObject < Base
      def self.applies_to?(_value)
        true
      end

      attr_reader :value_class

      # TODO: Default this to collection.class?
      def initialize(collection, value_class:)
        super(collection)

        @value_class = value_class
      end

      def to_diff(indent_level:, add_comma: false, **_rest)
        DiffFormatter.call(
          self,
          indent_level: indent_level,
          add_comma: add_comma,
          value_class: value_class,
        )
      end
    end
  end
end
