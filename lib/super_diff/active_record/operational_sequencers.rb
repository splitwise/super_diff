module SuperDiff
  module ActiveRecord
    module OperationalSequencers
      autoload(
        :ActiveRecordModel,
        "super_diff/active_record/operational_sequencers/active_record_model",
      )
      autoload(
        :ActiveRecordRelation,
        "super_diff/active_record/operational_sequencers/active_record_relation",
      )
    end
  end
end
