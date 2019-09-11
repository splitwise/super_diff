module SuperDiff
  module ActiveRecord
    module ObjectInspection
      module Inspectors
        autoload(
          :ActiveRecordModel,
          "super_diff/active_record/object_inspection/inspectors/active_record_model",
        )
        autoload(
          :ActiveRecordRelation,
          "super_diff/active_record/object_inspection/inspectors/active_record_relation",
        )
      end
    end
  end
end
