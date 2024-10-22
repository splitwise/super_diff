# frozen_string_literal: true

require 'super_diff/active_support'

require 'super_diff/active_record/differs'
require 'super_diff/active_record/inspection_tree_builders'
require 'super_diff/active_record/operation_trees'
require 'super_diff/active_record/operation_tree_builders'
require 'super_diff/active_record/operation_tree_flatteners'

module SuperDiff
  module ActiveRecord
    autoload :ObjectInspection, 'super_diff/active_record/object_inspection'

    SuperDiff.configure do |config|
      config.prepend_extra_differ_classes(Differs::ActiveRecordRelation)
      config.prepend_extra_operation_tree_builder_classes(
        OperationTreeBuilders::ActiveRecordModel,
        OperationTreeBuilders::ActiveRecordRelation
      )
      config.prepend_extra_inspection_tree_builder_classes(
        InspectionTreeBuilders::ActiveRecordModel,
        InspectionTreeBuilders::ActiveRecordRelation
      )
    end
  end
end

require 'super_diff/active_record/monkey_patches'
