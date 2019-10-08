module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        HashExcludingArgument =
          SuperDiff::ObjectInspection::InspectionTree.new do
            add_text "hash_not_including("

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
