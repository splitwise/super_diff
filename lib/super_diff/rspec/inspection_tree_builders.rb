# frozen_string_literal: true

module SuperDiff
  module RSpec
    module InspectionTreeBuilders
      autoload(
        :CollectionContainingExactly,
        'super_diff/rspec/inspection_tree_builders/collection_containing_exactly'
      )
      autoload(
        :CollectionIncluding,
        'super_diff/rspec/inspection_tree_builders/collection_including'
      )
      autoload :Double, 'super_diff/rspec/inspection_tree_builders/double'
      autoload(
        :GenericDescribableMatcher,
        'super_diff/rspec/inspection_tree_builders/generic_describable_matcher'
      )
      autoload(
        :HashIncluding,
        'super_diff/rspec/inspection_tree_builders/hash_including'
      )
      autoload(
        :InstanceOf,
        'super_diff/rspec/inspection_tree_builders/instance_of'
      )
      autoload :KindOf, 'super_diff/rspec/inspection_tree_builders/kind_of'
      autoload(
        :ObjectHavingAttributes,
        'super_diff/rspec/inspection_tree_builders/object_having_attributes'
      )
      autoload(
        :Primitive,
        'super_diff/rspec/inspection_tree_builders/primitive'
      )
      autoload(
        :ValueWithin,
        'super_diff/rspec/inspection_tree_builders/value_within'
      )
    end
  end
end
