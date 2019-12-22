module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        CollectionIncluding = SuperDiff::ObjectInspection::InspectionTree.new do
          def self.applies_to?(object)
            SuperDiff::RSpec.a_collection_including?(object)
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
