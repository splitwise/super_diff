module SuperDiff
  module Differs
    autoload :Base, "super_diff/differs/base"
    autoload :Array, "super_diff/differs/array"
    autoload :Empty, "super_diff/differs/empty"
    autoload :Hash, "super_diff/differs/hash"
    autoload :MultilineString, "super_diff/differs/multiline_string"
    autoload :Object, "super_diff/differs/object"

    DEFAULTS = [Array, Hash, MultilineString, Object, Empty].freeze
  end
end
