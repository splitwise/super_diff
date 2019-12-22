module SuperDiff
  module RSpec
    module OperationalSequencers
      autoload(
        :CollectionContainingExactly,
        "super_diff/rspec/operational_sequencers/collection_containing_exactly",
      )
      autoload(
        :CollectionIncluding,
        "super_diff/rspec/operational_sequencers/collection_including",
      )
      autoload(
        :HashIncluding,
        "super_diff/rspec/operational_sequencers/hash_including",
      )
      autoload(
        :ObjectHavingAttributes,
        "super_diff/rspec/operational_sequencers/object_having_attributes",
      )
    end
  end
end
