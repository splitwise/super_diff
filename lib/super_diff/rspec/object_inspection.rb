# frozen_string_literal: true

module SuperDiff
  module RSpec
    module ObjectInspection
      module InspectionTreeBuilders
        def self.const_missing(missing_const_name)
          if RSpec::InspectionTreeBuilders.const_defined?(missing_const_name)
            warn <<~WARNING
              WARNING: SuperDiff::RSpec::ObjectInspection::InspectionTreeBuilders::#{missing_const_name} is deprecated and will be removed in the next major release.
              Please use SuperDiff::RSpec::InspectionTreeBuilders::#{missing_const_name} instead.
              #{caller_locations.join("\n")}
            WARNING
            RSpec::InspectionTreeBuilders.const_get(missing_const_name)
          else
            super
          end
        end
      end
    end
  end
end
