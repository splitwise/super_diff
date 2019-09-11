module SuperDiff
  module ActiveRecord
    module ObjectInspection
      module Inspectors
        ActiveRecordRelation = SuperDiff::ObjectInspection::InspectionTree.new do
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
