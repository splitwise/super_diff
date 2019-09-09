module SuperDiff
  module EqualityMatchers
    autoload :Array, "super_diff/equality_matchers/array"
    autoload :Base, "super_diff/equality_matchers/base"
    autoload :Hash, "super_diff/equality_matchers/hash"
    autoload :MultiLineString, "super_diff/equality_matchers/multi_line_string"
    autoload :Object, "super_diff/equality_matchers/object"
    autoload :Primitive, "super_diff/equality_matchers/primitive"
    autoload(
      :SingleLineString,
      "super_diff/equality_matchers/single_line_string",
    )

    DEFAULTS = [
      Array,
      Hash,
      MultiLineString,
      SingleLineString,
      Object,
      Primitive,
    ].freeze
  end
end
