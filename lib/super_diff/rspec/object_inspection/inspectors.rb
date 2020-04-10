module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        autoload(
          :CollectionContainingExactly,
          "super_diff/rspec/object_inspection/inspectors/collection_containing_exactly",
        )
        autoload(
          :CollectionIncluding,
          "super_diff/rspec/object_inspection/inspectors/collection_including",
        )
        autoload(
          :HashIncluding,
          "super_diff/rspec/object_inspection/inspectors/hash_including",
        )
        autoload(
          :InstanceOf,
          "super_diff/rspec/object_inspection/inspectors/instance_of",
        )
        autoload(
          :KindOf,
          "super_diff/rspec/object_inspection/inspectors/kind_of",
        )
        autoload(
          :ObjectHavingAttributes,
          "super_diff/rspec/object_inspection/inspectors/object_having_attributes",
        )
        autoload(
          :ValueWithin,
          "super_diff/rspec/object_inspection/inspectors/value_within",
        )
      end
    end
  end
end
