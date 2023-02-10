module SuperDiff
  module ActiveRecord
    module OperationTreeBuilders
      autoload(
        :ActiveRecordModel,
        "super_diff/active_record/operation_tree_builders/active_record_model"
      )
      autoload(
        :ActiveRecordRelation,
        "super_diff/active_record/operation_tree_builders/active_record_relation"
      )
    end
  end
end
