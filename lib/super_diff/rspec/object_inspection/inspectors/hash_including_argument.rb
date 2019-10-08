module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        HashIncludingArgument =
          SuperDiff::ObjectInspection::InspectionTree.new do
            add_text "hash_including("

            nested do |matcher|
              insert_hash_inspection_of(
                matcher.instance_variable_get("@expected"),
                initial_break: nil,
              )
            end

            add_break
            add_text ")"
          end
      end
    end
  end
end
