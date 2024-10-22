# frozen_string_literal: true

require 'super_diff/active_support/differs'
require 'super_diff/active_support/inspection_tree_builders'
require 'super_diff/active_support/operation_trees'
require 'super_diff/active_support/operation_tree_builders'
require 'super_diff/active_support/operation_tree_flatteners'

module SuperDiff
  module ActiveSupport
    autoload :ObjectInspection, 'super_diff/active_support/object_inspection'

    SuperDiff.configure do |config|
      config.prepend_extra_differ_classes(Differs::HashWithIndifferentAccess)
      config.prepend_extra_operation_tree_builder_classes(
        OperationTreeBuilders::HashWithIndifferentAccess
      )
      config.prepend_extra_inspection_tree_builder_classes(
        InspectionTreeBuilders::HashWithIndifferentAccess,
        InspectionTreeBuilders::OrderedOptions
      )
    end
  end
end
