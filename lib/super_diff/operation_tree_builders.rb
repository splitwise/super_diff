# frozen_string_literal: true

module SuperDiff
  module OperationTreeBuilders
    def self.const_missing(missing_const_name)
      if missing_const_name == :Base
        warn <<~WARNING
          WARNING: SuperDiff::OperationTreeBuilders::#{missing_const_name} is deprecated and will be removed in the next major release.
          Please use SuperDiff::Core::AbstractOperationTreeBuilder instead.
          #{caller_locations.join("\n")}
        WARNING
        Core::AbstractOperationTreeBuilder
      elsif Basic::OperationTreeBuilders.const_defined?(missing_const_name)
        warn <<~WARNING
          WARNING: SuperDiff::OperationTreeBuilders::#{missing_const_name} is deprecated and will be removed in the next major release.
          Please use SuperDiff::Basic::OperationTreeBuilders::#{missing_const_name} instead.
          #{caller_locations.join("\n")}
        WARNING
        Basic::OperationTreeBuilders.const_get(missing_const_name)
      else
        super
      end
    end
  end
end
