module SuperDiff
  module Operations
    class UnaryOperation
      attr_reader(
        :name,
        :collection,
        :key,
        :value,
        # TODO: Is this even used??
        :index,
        :index_in_collection,
      )

      def initialize(
        name:,
        collection:,
        key:,
        value:,
        # TODO: Is this even used??
        index:,
        index_in_collection: index
      )
        @name = name
        @collection = collection
        @key = key
        @value = value
        # TODO: Is this even used??
        @index = index
        @index_in_collection = index_in_collection
      end

      def should_add_comma_after_displaying?
        index_in_collection < collection.size - 1
      end
    end
  end
end
