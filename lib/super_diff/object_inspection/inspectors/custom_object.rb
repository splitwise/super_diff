module SuperDiff
  module ObjectInspection
    module Inspectors
      CustomObject = InspectionTree.new do
        add_text do |object|
          "#<#{object.class}"
        end

        when_multiline do
          add_text " {"
        end

        nested do |object|
          insert_hash_inspection_of(object.attributes_for_super_diff)
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
