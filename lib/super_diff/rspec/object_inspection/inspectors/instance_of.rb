module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        class InstanceOf < SuperDiff::ObjectInspection::Inspectors::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.an_instance_of_something?(value)
          end

          protected

          def inspection_tree
            SuperDiff::ObjectInspection::InspectionTree.new do
              add_text do |aliased_matcher|
                "#<an instance of #{aliased_matcher.expected}>"
              end
            end
          end
        end
      end
    end
  end
end
