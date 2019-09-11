module SuperDiff
  module ActiveRecord
    module DiffFormatters
      autoload(
        :ActiveRecordRelation,
        "super_diff/active_record/diff_formatters/active_record_relation",
      )
    end
  end
end
