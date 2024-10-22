# frozen_string_literal: true

module SuperDiff
  module ActiveSupport
    module ObjectInspection
      module InspectionTreeBuilders
        def self.const_missing(missing_const_name)
          if ActiveSupport::InspectionTreeBuilders.const_defined?(
            missing_const_name
          )
            warn <<~WARNING
              WARNING: SuperDiff::ActiveSupport::ObjectInspection::InspectionTreeBuilders::#{missing_const_name} is deprecated and will be removed in the next major release.
              Please use SuperDiff::ActiveSupport::InspectionTreeBuilders::#{missing_const_name} instead.
              #{caller_locations.join("\n")}
            WARNING
            ActiveSupport::InspectionTreeBuilders.const_get(missing_const_name)
          else
            super
          end
        end
      end
    end
  end
end
