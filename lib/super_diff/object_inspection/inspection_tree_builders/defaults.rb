module SuperDiff
  module ObjectInspection
    module InspectionTreeBuilders
      DEFAULTS = [
        CustomObject,
        Array,
        Hash,
        Primitive,
        TimeLike,
        DefaultObject,
      ].freeze
    end
  end
end
