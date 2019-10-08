module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        DuckTypeArgument =
          SuperDiff::ObjectInspection::InspectionTree.new do
            add_text "duck_type("

            nested do |matcher|
              insert_array_inspection_of(
                matcher.instance_variable_get("@methods_to_respond_to"),
              )
            end

            add_break
            add_text ")"
          end
      end
    end
  end
end
