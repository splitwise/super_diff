module SuperDiff
  module Operations
    class BinaryOperation
      extend AttrExtras.mixin

      rattr_initialize(
        [
          :name!,
          :left_collection!,
          :right_collection!,
          :left_key!,
          :right_key!,
          :left_value!,
          :right_value!,
          :left_index!,
          :right_index!,
          child_operations: [],
        ],
      )

      def should_add_comma_after_displaying?
        left_index < left_collection.size - 1 ||
          right_index < right_collection.size - 1
      end
    end
  end
end
