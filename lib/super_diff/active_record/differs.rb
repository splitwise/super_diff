module SuperDiff
  module ActiveRecord
    module Differs
      autoload(
        :ActiveRecordRelation,
        "super_diff/active_record/differs/active_record_relation"
      )
    end
  end
end
