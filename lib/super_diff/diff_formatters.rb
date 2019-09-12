module SuperDiff
  module DiffFormatters
    autoload :Array, "super_diff/diff_formatters/array"
    autoload :Base, "super_diff/diff_formatters/base"
    autoload :Collection, "super_diff/diff_formatters/collection"
    autoload :CustomObject, "super_diff/diff_formatters/custom_object"
    autoload :DefaultObject, "super_diff/diff_formatters/default_object"
    autoload :Hash, "super_diff/diff_formatters/hash"
    autoload :MultilineString, "super_diff/diff_formatters/multiline_string"

    # TODO: Why doesn't this include CustomObject and DefaultObject?
    DEFAULTS = [Array, Hash, MultilineString].freeze
  end
end
