module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        InstanceOf = SuperDiff::ObjectInspection::InspectionTree.new do
          add_text do |aliased_matcher|
            "#<an instance of #{aliased_matcher.expected}>"
          end
        end
      end
    end
  end
end
