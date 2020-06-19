module SuperDiff
  module ActiveRecord
    module OperationTreeFlatteners
      autoload(
        :ActiveRecordRelation,
        "super_diff/active_record/operation_tree_flatteners/active_record_relation",
      )
    end
  end
end
