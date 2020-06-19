module SuperDiff
  module ActiveRecord
    module ObjectInspection
      module InspectionTreeBuilders
        autoload(
          :ActiveRecordModel,
          "super_diff/active_record/object_inspection/inspection_tree_builders/active_record_model",
        )
        autoload(
          :ActiveRecordRelation,
          "super_diff/active_record/object_inspection/inspection_tree_builders/active_record_relation",
        )
      end
    end
  end
end
