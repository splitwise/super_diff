module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        CollectionContainingExactly = SuperDiff::ObjectInspection::InspectionTree.new do
          add_text "#<a collection containing exactly ("

          nested do |aliased_matcher|
            insert_array_inspection_of(aliased_matcher.expected)
          end

          add_break
          add_text ")>"
        end
      end
    end
  end
end
