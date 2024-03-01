module SuperDiff
  module OperationTreeBuilders
    def self.const_missing(missing_const_name)
      if missing_const_name == :Base
        warn <<~EOT
          WARNING: SuperDiff::OperationTreeBuilders::#{missing_const_name} is deprecated and will be removed in the next major release.
          Please use SuperDiff::Core::AbstractOperationTreeBuilder instead.
          #{caller_locations.join("\n")}
        EOT
        Core::AbstractOperationTreeBuilder
      elsif Basic::OperationTreeBuilders.const_defined?(missing_const_name)
        warn <<~EOT
          WARNING: SuperDiff::OperationTreeBuilders::#{missing_const_name} is deprecated and will be removed in the next major release.
          Please use SuperDiff::Basic::OperationTreeBuilders::#{missing_const_name} instead.
          #{caller_locations.join("\n")}
        EOT
        Basic::OperationTreeBuilders.const_get(missing_const_name)
      else
        super
      end
    end
  end
end
