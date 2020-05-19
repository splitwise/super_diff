module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        class HashIncluding < SuperDiff::ObjectInspection::Inspectors::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.a_hash_including_something?(value)
          end

          protected

          def inspection_tree
            SuperDiff::ObjectInspection::InspectionTree.new do
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
  end
end
