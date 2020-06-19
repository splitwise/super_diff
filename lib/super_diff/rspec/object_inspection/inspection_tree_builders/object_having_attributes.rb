module SuperDiff
  module RSpec
    module ObjectInspection
      module InspectionTreeBuilders
        class ObjectHavingAttributes < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.an_object_having_some_attributes?(value)
          end

          def call
            SuperDiff::ObjectInspection::InspectionTree.new do
              as_lines_when_rendering_to_lines(collection_bookend: :open) do
                add_text "#<an object having attributes ("
              end

              nested do |aliased_matcher|
                insert_hash_inspection_of(aliased_matcher.expected)
              end

              as_lines_when_rendering_to_lines(collection_bookend: :close) do
                add_text ")>"
              end
            end
          end
        end
      end
    end
  end
end
