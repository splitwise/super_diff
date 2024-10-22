# frozen_string_literal: true

module SuperDiff
  module ActiveRecord
    module ObjectInspection
      module InspectionTreeBuilders
        def self.const_missing(missing_const_name)
          if ActiveRecord::InspectionTreeBuilders.const_defined?(
            missing_const_name
          )
            warn <<~WARNING
              WARNING: SuperDiff::ActiveRecord::ObjectInspection::InspectionTreeBuilders::#{missing_const_name} is deprecated and will be removed in the next major release.
              Please use SuperDiff::ActiveRecord::InspectionTreeBuilders::#{missing_const_name} instead.
              #{caller_locations.join("\n")}
            WARNING
            ActiveRecord::InspectionTreeBuilders.const_get(missing_const_name)
          else
            super
          end
        end
      end
    end
  end
end
