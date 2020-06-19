module SuperDiff
  module ObjectInspection
    module InspectionTreeBuilders
      autoload(
        :Base,
        "super_diff/object_inspection/inspection_tree_builders/base",
      )
      autoload(
        :Array,
        "super_diff/object_inspection/inspection_tree_builders/array",
      )
      autoload(
        :CustomObject,
        "super_diff/object_inspection/inspection_tree_builders/custom_object",
      )
      autoload(
        :DefaultObject,
        "super_diff/object_inspection/inspection_tree_builders/default_object",
      )
      autoload(
        :Hash,
        "super_diff/object_inspection/inspection_tree_builders/hash",
      )
      autoload(
        :Main,
        "super_diff/object_inspection/inspection_tree_builders/main",
      )
      autoload(
        :Primitive,
        "super_diff/object_inspection/inspection_tree_builders/primitive",
      )
      autoload(
        :String,
        "super_diff/object_inspection/inspection_tree_builders/string",
      )
      autoload(
        :TimeLike,
        "super_diff/object_inspection/inspection_tree_builders/time_like",
      )
    end
  end
end

require "super_diff/object_inspection/inspection_tree_builders/defaults"
