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
          children: [],
        ],
      )
    end
  end
end
