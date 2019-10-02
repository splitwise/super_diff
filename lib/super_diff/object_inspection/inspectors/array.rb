module SuperDiff
  module ObjectInspection
    module Inspectors
      Array = InspectionTree.new do
        when_empty do
          add_text "[]"
        end

        when_non_empty do
          add_text "["

          nested do |array|
            insert_array_inspection_of(array)
          end

          add_break
          add_text "]"
        end
      end
    end
  end
end
