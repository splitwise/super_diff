module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        autoload(
          :ArrayIncludingArgument,
          "super_diff/rspec/object_inspection/inspectors/array_including_argument",
        )
        autoload(
          :CollectionContainingExactly,
          "super_diff/rspec/object_inspection/inspectors/collection_containing_exactly",
        )
        autoload(
          :CollectionIncluding,
          "super_diff/rspec/object_inspection/inspectors/collection_including",
        )
        autoload(
          :DuckTypeArgument,
          "super_diff/rspec/object_inspection/inspectors/duck_type_argument",
        )
        autoload(
          :HashExcludingArgument,
          "super_diff/rspec/object_inspection/inspectors/hash_excluding_argument",
        )
        autoload(
          :HashIncluding,
          "super_diff/rspec/object_inspection/inspectors/hash_including",
        )
        autoload(
          :HashIncludingArgument,
          "super_diff/rspec/object_inspection/inspectors/hash_including_argument",
        )
        autoload(
          :KindOfArgument,
          "super_diff/rspec/object_inspection/inspectors/kind_of_argument",
        )
        autoload(
          :Matcher,
          "super_diff/rspec/object_inspection/inspectors/matcher",
        )
        autoload(
          :ObjectHavingAttributes,
          "super_diff/rspec/object_inspection/inspectors/object_having_attributes",
        )
      end
    end
  end
end
