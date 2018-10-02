module SuperDiff
  module Operations
    class UnaryOperation
      attr_reader(
        :name,
        :collection,
        :key,
        :value,
        :index,
      )

      def initialize(name:, collection:, key:, value:, index:)
        @name = name
        @collection = collection
        @key = key
        @value = value
        @index = index
      end

      def should_add_comma_after_displaying?
        index < collection.size - 1
      end
    end
  end
end
