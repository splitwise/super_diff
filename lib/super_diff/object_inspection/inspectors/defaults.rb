module SuperDiff
  module ObjectInspection
    module Inspectors
      DEFAULTS = [
        CustomObject,
        Array,
        Hash,
        Primitive,
        String,
        TimeLike,
        DefaultObject,
      ].freeze
    end
  end
end
