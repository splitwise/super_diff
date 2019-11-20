module SuperDiff
  module ObjectInspection
    module Inspectors
      autoload :Array, "super_diff/object_inspection/inspectors/array"
      autoload(
        :CustomObject,
        "super_diff/object_inspection/inspectors/custom_object",
      )
      autoload(
        :DefaultObject,
        "super_diff/object_inspection/inspectors/default_object",
      )
      autoload :Hash, "super_diff/object_inspection/inspectors/hash"
      autoload :Primitive, "super_diff/object_inspection/inspectors/primitive"
      autoload :String, "super_diff/object_inspection/inspectors/string"
      autoload :Time, "super_diff/object_inspection/inspectors/time"
    end
  end
end
