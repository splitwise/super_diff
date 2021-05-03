module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        class CollectionIncluding < SuperDiff::ObjectInspection::Inspectors::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.a_collection_including_something?(value) || SuperDiff::RSpec.array_including_something?(value)
          end

          protected

          def inspection_tree
            SuperDiff::ObjectInspection::InspectionTree.new do
              add_text "#<a collection including ("

              nested do |value|
                array = if SuperDiff::RSpec.a_collection_including_something?(value)
                          value.expecteds
                        else
                          value.instance_variable_get(:@expected)
                        end
                insert_array_inspection_of(array)
              end

              add_break
              add_text ")>"
            end
          end
        end
      end
    end
  end
end
