# frozen_string_literal: true

module SuperDiff
  module Basic
    module Differs
      autoload :Array, 'super_diff/basic/differs/array'
      autoload :CustomObject, 'super_diff/basic/differs/custom_object'
      autoload :DateLike, 'super_diff/basic/differs/date_like'
      autoload :DefaultObject, 'super_diff/basic/differs/default_object'
      autoload :Hash, 'super_diff/basic/differs/hash'
      autoload :MultilineString, 'super_diff/basic/differs/multiline_string'
      autoload :TimeLike, 'super_diff/basic/differs/time_like'

      class Main
        def self.call(*args)
          warn <<~WARNING
            WARNING: SuperDiff::Differs::Main.call(...) is deprecated and will be removed in the next major release.
            Please use SuperDiff.diff(...) instead.
            #{caller_locations.join("\n")}
          WARNING
          SuperDiff.diff(*args)
        end
      end
    end
  end
end
