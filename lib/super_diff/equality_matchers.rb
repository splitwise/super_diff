module SuperDiff
  module EqualityMatchers
    autoload :Array, "super_diff/equality_matchers/array"
    autoload :Base, "super_diff/equality_matchers/base"
    autoload :Hash, "super_diff/equality_matchers/hash"
    autoload :MultilineString, "super_diff/equality_matchers/multiline_string"
    autoload :Object, "super_diff/equality_matchers/object"
    autoload :Primitive, "super_diff/equality_matchers/primitive"
    autoload(
      :SinglelineString,
      "super_diff/equality_matchers/singleline_string",
    )

    DEFAULTS = [
      Array,
      Hash,
      MultilineString,
      SinglelineString,
      Object,
      Primitive,
    ].freeze
  end
end
