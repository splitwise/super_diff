module SuperDiff
  module DiffFormatters
    autoload :Array, "super_diff/diff_formatters/array"
    autoload :Base, "super_diff/diff_formatters/base"
    autoload :Collection, "super_diff/diff_formatters/collection"
    autoload :Hash, "super_diff/diff_formatters/hash"
    autoload :MultilineString, "super_diff/diff_formatters/multiline_string"
    autoload :Object, "super_diff/diff_formatters/object"

    DEFAULTS = [Array, Hash, MultilineString].freeze
  end
end
