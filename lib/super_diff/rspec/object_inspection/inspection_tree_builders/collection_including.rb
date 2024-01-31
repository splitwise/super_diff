module SuperDiff
  module RSpec
    module ObjectInspection
      module InspectionTreeBuilders
        class CollectionIncluding < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.a_collection_including_something?(value) ||
              SuperDiff::RSpec.array_including_something?(value)
          end

          def call
            SuperDiff::ObjectInspection::InspectionTree.new do |t1|
              # stree-ignore
              t1.as_lines_when_rendering_to_lines(
                collection_bookend: :open
              ) do |t2|
                t2.add_text "#<a collection including ("
              end

              t1.nested do |t2|
                if SuperDiff::RSpec.a_collection_including_something?(object)
                  t2.insert_array_inspection_of(object.expecteds)
                else
                  t2.insert_array_inspection_of(
                    object.instance_variable_get(:@expected)
                  )
                end
              end

              # stree-ignore
              t1.as_lines_when_rendering_to_lines(
                collection_bookend: :close
              ) do |t2|
                t2.add_text ")>"
              end
            end
          end
        end
      end
    end
  end
end
