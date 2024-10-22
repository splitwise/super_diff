# frozen_string_literal: true

module SuperDiff
  module OperationTreeFlatteners
    def self.const_missing(missing_const_name)
      if missing_const_name == :Base
        warn <<~WARNING
          WARNING: SuperDiff::OperationTreeFlatteners::#{missing_const_name} is deprecated and will be removed in the next major release.
          Please use SuperDiff::Core::AbstractOperationTreeFlattener instead.
          #{caller_locations.join("\n")}
        WARNING
        Core::AbstractOperationTreeFlattener
      elsif Basic::OperationTreeFlatteners.const_defined?(missing_const_name)
        warn <<~WARNING
          WARNING: SuperDiff::OperationTreeFlatteners::#{missing_const_name} is deprecated and will be removed in the next major release.
          Please use SuperDiff::Basic::OperationTreeFlatteners::#{missing_const_name} instead.
          #{caller_locations.join("\n")}
        WARNING
        Basic::OperationTreeFlatteners.const_get(missing_const_name)
      else
        super
      end
    end
  end
end
