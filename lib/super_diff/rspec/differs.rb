module SuperDiff
  module RSpec
    module Differs
      autoload(
        :CollectionContainingExactly,
        "super_diff/rspec/differs/collection_containing_exactly"
      )
      autoload(
        :CollectionIncluding,
        "super_diff/rspec/differs/collection_including"
      )
      autoload :HashIncluding, "super_diff/rspec/differs/hash_including"
      autoload(
        :ObjectHavingAttributes,
        "super_diff/rspec/differs/object_having_attributes"
      )
    end
  end
end
