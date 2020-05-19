module SuperDiff
  module ActiveRecord
    module ObjectInspection
      module Inspectors
        class ActiveRecordRelation < SuperDiff::ObjectInspection::Inspectors::Base
          def self.applies_to?(value)
            value.is_a?(::ActiveRecord::Relation)
          end

          protected

          def inspection_tree
            SuperDiff::ObjectInspection::InspectionTree.new do
              add_text "#<ActiveRecord::Relation ["

              nested do |array|
                insert_array_inspection_of(array)
              end

              add_break
              add_text "]>"
            end
          end
        end
      end
    end
  end
end
