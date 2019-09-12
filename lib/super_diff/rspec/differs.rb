module SuperDiff
  module RSpec
    module Differs
      autoload(
        :CollectionContainingExactly,
        "super_diff/rspec/differs/collection_containing_exactly",
      )
      autoload :PartialArray, "super_diff/rspec/differs/partial_array"
      autoload :PartialHash, "super_diff/rspec/differs/partial_hash"
      autoload :PartialObject, "super_diff/rspec/differs/partial_object"
    end
  end
end
