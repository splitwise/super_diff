module SuperDiff
  module Differs
    autoload :Base, "super_diff/differs/base"
    autoload :Array, "super_diff/differs/array"
    autoload :Empty, "super_diff/differs/empty"
    autoload :Hash, "super_diff/differs/hash"
    autoload :MultiLineString, "super_diff/differs/multi_line_string"
    autoload :Object, "super_diff/differs/object"

    DEFAULTS = [Array, Hash, MultiLineString, Object, Empty].freeze
  end
end
