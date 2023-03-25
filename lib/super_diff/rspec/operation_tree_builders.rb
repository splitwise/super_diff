module SuperDiff
  module RSpec
    module OperationTreeBuilders
      autoload(
        :CollectionContainingExactly,
        "super_diff/rspec/operation_tree_builders/collection_containing_exactly"
      )
      autoload(
        :CollectionIncluding,
        "super_diff/rspec/operation_tree_builders/collection_including"
      )
      autoload(
        :HashIncluding,
        "super_diff/rspec/operation_tree_builders/hash_including"
      )
      autoload(
        :ObjectHavingAttributes,
        "super_diff/rspec/operation_tree_builders/object_having_attributes"
      )
    end
  end
end
