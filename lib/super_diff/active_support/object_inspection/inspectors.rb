module SuperDiff
  module ActiveSupport
    module ObjectInspection
      module Inspectors
        autoload(
          :HashWithIndifferentAccess,
          "super_diff/active_support/object_inspection/inspectors/hash_with_indifferent_access",
        )
      end
    end
  end
end
