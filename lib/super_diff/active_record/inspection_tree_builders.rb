# frozen_string_literal: true

module SuperDiff
  module ActiveRecord
    module InspectionTreeBuilders
      autoload(
        :ActiveRecordModel,
        'super_diff/active_record/inspection_tree_builders/active_record_model'
      )
      autoload(
        :ActiveRecordRelation,
        'super_diff/active_record/inspection_tree_builders/active_record_relation'
      )
    end
  end
end
