module SuperDiff
  module OperationTreeFlatteners
    def self.const_missing(missing_const_name)
      if missing_const_name == :Base
        warn <<~EOT
          WARNING: SuperDiff::OperationTreeFlatteners::#{missing_const_name} is deprecated and will be removed in the next major release.
          Please use SuperDiff::Core::AbstractOperationTreeFlattener instead.
          #{caller_locations.join("\n")}
        EOT
        Core::AbstractOperationTreeFlattener
      elsif Basic::OperationTreeFlatteners.const_defined?(missing_const_name)
        warn <<~EOT
          WARNING: SuperDiff::OperationTreeFlatteners::#{missing_const_name} is deprecated and will be removed in the next major release.
          Please use SuperDiff::Basic::OperationTreeFlatteners::#{missing_const_name} instead.
          #{caller_locations.join("\n")}
        EOT
        Basic::OperationTreeFlatteners.const_get(missing_const_name)
      else
        super
      end
    end
  end
end
