module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        ArrayIncludingArgument =
          SuperDiff::ObjectInspection::InspectionTree.new do
            add_text "array_including("

            nested do |matcher|
              insert_array_inspection_of(
                matcher.instance_variable_get("@expected"),
              )
            end

            add_break
            add_text ")"
          end
      end
    end
  end
end
