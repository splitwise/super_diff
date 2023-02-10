module SuperDiff
  module RSpec
    module ObjectInspection
      module InspectionTreeBuilders
        class HashIncluding < SuperDiff::ObjectInspection::InspectionTreeBuilders::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.a_hash_including_something?(value) ||
              SuperDiff::RSpec.hash_including_something?(value)
          end

          def call
            SuperDiff::ObjectInspection::InspectionTree.new do
              as_lines_when_rendering_to_lines(collection_bookend: :open) do
                add_text "#<a hash including ("
              end

              nested do |value|
                hash =
                  if SuperDiff::RSpec.a_hash_including_something?(value)
                    value.expecteds.first
                  else
                    value.instance_variable_get(:@expected)
                  end

                insert_hash_inspection_of(hash)
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
