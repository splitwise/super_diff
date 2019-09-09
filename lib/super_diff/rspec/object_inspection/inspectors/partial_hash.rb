module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        PartialHash = SuperDiff::ObjectInspection::InspectionTree.new do
          add_text "#<a hash including ("

          nested do |aliased_matcher|
            insert_hash_inspection_of(
              aliased_matcher.expecteds.first,
              initial_break: nil,
            )
          end

          add_break
          add_text ")>"
        end
      end
    end
  end
end
