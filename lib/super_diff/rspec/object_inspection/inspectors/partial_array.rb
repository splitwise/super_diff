module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        PartialArray = SuperDiff::ObjectInspection::InspectionTree.new do
          def self.applies_to?(object)
            SuperDiff::RSpec.partial_array?(object)
          end

          add_text "#<a collection including ("

          nested do |aliased_matcher|
            insert_array_inspection_of(aliased_matcher.expecteds)
          end

          add_break
          add_text ")>"
        end
      end
    end
  end
end
