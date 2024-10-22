# frozen_string_literal: true

module SuperDiff
  module Basic
    module DiffFormatters
      autoload :Collection, 'super_diff/basic/diff_formatters/collection'
      autoload(
        :MultilineString,
        'super_diff/basic/diff_formatters/multiline_string'
      )
    end
  end
end
