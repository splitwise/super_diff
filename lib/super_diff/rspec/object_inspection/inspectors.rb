module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        autoload(
          :CollectionContainingExactly,
          "super_diff/rspec/object_inspection/inspectors/collection_containing_exactly",
        )
        autoload(
          :PartialArray,
          "super_diff/rspec/object_inspection/inspectors/partial_array",
        )
        autoload(
          :PartialHash,
          "super_diff/rspec/object_inspection/inspectors/partial_hash",
        )
        autoload(
          :PartialObject,
          "super_diff/rspec/object_inspection/inspectors/partial_object",
        )
      end
    end
  end
end
