module SuperDiff
  module ActiveRecord
    module ObjectInspection
      autoload(
        :Inspector,
        "super_diff/active_record/object_inspection/inspector",
      )
      autoload(
        :MapExtension,
        "super_diff/active_record/object_inspection/map_extension",
      )
    end
  end
end
