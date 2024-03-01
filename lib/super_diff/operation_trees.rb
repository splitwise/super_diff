module SuperDiff
  module OperationTrees
    def self.const_missing(missing_const_name)
      if missing_const_name == :Base
        warn <<~EOT
          WARNING: SuperDiff::OperationTrees::#{missing_const_name} is deprecated and will be removed in the next major release.
          Please use SuperDiff::Core::AbstractOperationTree instead.
          #{caller_locations.join("\n")}
        EOT
        Core::AbstractOperationTree
      elsif Basic::OperationTrees.const_defined?(missing_const_name)
        warn <<~EOT
          WARNING: SuperDiff::OperationTrees::#{missing_const_name} is deprecated and will be removed in the next major release.
          Please use SuperDiff::Basic::OperationTrees::#{missing_const_name} instead.
          #{caller_locations.join("\n")}
        EOT
        Basic::OperationTrees.const_get(missing_const_name)
      else
        super
      end
    end
  end
end
