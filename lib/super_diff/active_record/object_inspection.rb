module SuperDiff
  module ActiveRecord
    module ObjectInspection
      autoload(
        :Inspectors,
        "super_diff/active_record/object_inspection/inspectors",
      )
      autoload(
        :MapExtension,
        "super_diff/active_record/object_inspection/map_extension",
      )
    end
  end
end
