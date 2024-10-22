# frozen_string_literal: true

module SuperDiff
  module OperationTrees
    def self.const_missing(missing_const_name)
      if missing_const_name == :Base
        warn <<~WARNING
          WARNING: SuperDiff::OperationTrees::#{missing_const_name} is deprecated and will be removed in the next major release.
          Please use SuperDiff::Core::AbstractOperationTree instead.
          #{caller_locations.join("\n")}
        WARNING
        Core::AbstractOperationTree
      elsif Basic::OperationTrees.const_defined?(missing_const_name)
        warn <<~WARNING
          WARNING: SuperDiff::OperationTrees::#{missing_const_name} is deprecated and will be removed in the next major release.
          Please use SuperDiff::Basic::OperationTrees::#{missing_const_name} instead.
          #{caller_locations.join("\n")}
        WARNING
        Basic::OperationTrees.const_get(missing_const_name)
      else
        super
      end
    end
  end
end
