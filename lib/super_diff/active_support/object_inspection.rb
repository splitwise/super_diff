module SuperDiff
  module ActiveSupport
    module ObjectInspection
      autoload(
        :Inspectors,
        "super_diff/active_support/object_inspection/inspectors",
      )
      autoload(
        :MapExtension,
        "super_diff/active_support/object_inspection/map_extension",
      )
    end
  end
end
