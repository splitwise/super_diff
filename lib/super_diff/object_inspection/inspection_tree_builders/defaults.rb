module SuperDiff
  module ObjectInspection
    module InspectionTreeBuilders
      DEFAULTS = [
        CustomObject,
        Array,
        Hash,
        Primitive,
        TimeLike,
        DateLike,
        DefaultObject
      ].freeze
    end
  end
end
