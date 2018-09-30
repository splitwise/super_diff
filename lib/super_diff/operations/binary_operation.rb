module SuperDiff
  module Operations
    class BinaryOperation
      attr_reader(
        :name,
        :left_collection,
        :right_collection,
        :left_key,
        :right_key,
        :left_value,
        :right_value,
        :left_index,
        :right_index,
        :child_operations
      )

      def initialize(
        name:,
        left_collection:,
        right_collection:,
        left_index:,
        right_index:,
        left_key:,
        right_key:,
        left_value:,
        right_value:,
        child_operations: []
      )
        @name = name
        @left_collection = left_collection
        @right_collection = right_collection
        @left_index = left_index
        @right_index = right_index
        @left_key = left_key
        @right_key = right_key
        @left_value = left_value
        @right_value = right_value
        @child_operations = child_operations
      end

      def should_add_comma_after_displaying?
        left_index < left_collection.size - 1 ||
          right_index < right_collection.size - 1
      end
    end
  end
end
