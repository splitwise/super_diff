module SuperDiff
  module Differs
    autoload :Array, "super_diff/differs/array"
    autoload :Base, "super_diff/differs/base"
    autoload :CustomObject, "super_diff/differs/custom_object"
    autoload :DefaultObject, "super_diff/differs/default_object"
    autoload :Empty, "super_diff/differs/empty"
    autoload :Hash, "super_diff/differs/hash"
    autoload :MultilineString, "super_diff/differs/multiline_string"

    DEFAULTS = [
      Array,
      Hash,
      MultilineString,
      CustomObject,
      DefaultObject,
      Empty,
    ].freeze
  end
end
