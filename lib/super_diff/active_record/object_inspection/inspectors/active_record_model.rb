module SuperDiff
  module ActiveRecord
    module ObjectInspection
      module Inspectors
        ActiveRecordModel = SuperDiff::ObjectInspection::InspectionTree.new do
          add_text do |object|
            "#<#{object.class} "
          end

          when_multiline do
            add_text "{"
          end

          nested do |object|
            add_break

            insert_separated_list(
              ["id"] + (object.attributes.keys.sort - ["id"]),
              separator: ",",
            ) do |name|
              add_text name
              add_text ": "
              add_inspection_of object.read_attribute(name)
            end
          end

          add_break

          when_multiline do
            add_text "}"
          end

          add_text ">"
        end
      end
    end
  end
end
