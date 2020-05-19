module SuperDiff
  module ObjectInspection
    module Inspectors
      autoload :Base, "super_diff/object_inspection/inspectors/base"
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
      autoload :Main, "super_diff/object_inspection/inspectors/main"
      autoload :Primitive, "super_diff/object_inspection/inspectors/primitive"
      autoload :String, "super_diff/object_inspection/inspectors/string"
      autoload :TimeLike, "super_diff/object_inspection/inspectors/time_like"
    end
  end
end

require "super_diff/object_inspection/inspectors/defaults"
