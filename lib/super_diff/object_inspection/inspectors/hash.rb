module SuperDiff
  module ObjectInspection
    module Inspectors
      Hash = InspectionTree.new do
        when_empty do
          add_text "{}"
        end

        when_non_empty do
          add_text "{"

          nested do |hash|
            insert_hash_inspection_of(hash)
          end

          add_break " "
          add_text "}"
        end
      end
    end
  end
end
