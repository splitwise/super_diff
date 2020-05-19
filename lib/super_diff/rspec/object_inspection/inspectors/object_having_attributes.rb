module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        class ObjectHavingAttributes < SuperDiff::ObjectInspection::Inspectors::Base
          def self.applies_to?(value)
            SuperDiff::RSpec.an_object_having_some_attributes?(value)
          end

          protected

          def inspection_tree
            SuperDiff::ObjectInspection::InspectionTree.new do
              add_text "#<an object having attributes ("

              nested do |aliased_matcher|
                insert_hash_inspection_of(
                  aliased_matcher.expected,
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
