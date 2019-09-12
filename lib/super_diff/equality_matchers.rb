module SuperDiff
  module EqualityMatchers
    autoload :Array, "super_diff/equality_matchers/array"
    autoload :Base, "super_diff/equality_matchers/base"
    autoload :Hash, "super_diff/equality_matchers/hash"
    autoload :MultilineString, "super_diff/equality_matchers/multiline_string"
    autoload :Default, "super_diff/equality_matchers/default"
    autoload :Primitive, "super_diff/equality_matchers/primitive"
    autoload(
      :SinglelineString,
      "super_diff/equality_matchers/singleline_string",
    )

    DEFAULTS = [
      Primitive,
      Array,
      Hash,
      MultilineString,
      SinglelineString,
      Default,
    ].freeze
  end
end
