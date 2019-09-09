module SuperDiff
  module RSpec
    module OperationalSequencers
      autoload(
        :CollectionContainingExactly,
        "super_diff/rspec/operational_sequencers/collection_containing_exactly",
      )
      autoload(
        :PartialArray,
        "super_diff/rspec/operational_sequencers/partial_array",
      )
      autoload(
        :PartialHash,
        "super_diff/rspec/operational_sequencers/partial_hash",
      )
      autoload(
        :PartialObject,
        "super_diff/rspec/operational_sequencers/partial_object",
      )
    end
  end
end
