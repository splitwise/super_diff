module SuperDiff
  module DiffFormatters
    autoload :Array, "super_diff/diff_formatters/array"
    autoload :Base, "super_diff/diff_formatters/base"
    autoload :Collection, "super_diff/diff_formatters/collection"
    autoload :CustomObject, "super_diff/diff_formatters/custom_object"
    autoload :DefaultObject, "super_diff/diff_formatters/default_object"
    autoload :Hash, "super_diff/diff_formatters/hash"
    autoload :Main, "super_diff/diff_formatters/main"
    autoload :MultilineString, "super_diff/diff_formatters/multiline_string"
  end
end

require "super_diff/diff_formatters/defaults"
