# frozen_string_literal: true

module SuperDiff
  module ActiveSupport
    module InspectionTreeBuilders
      autoload(
        :HashWithIndifferentAccess,
        'super_diff/active_support/inspection_tree_builders/hash_with_indifferent_access'
      )
      autoload(
        :OrderedOptions,
        'super_diff/active_support/inspection_tree_builders/ordered_options'
      )
    end
  end
end
