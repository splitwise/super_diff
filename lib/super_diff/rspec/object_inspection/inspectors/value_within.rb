module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        ValueWithin = SuperDiff::ObjectInspection::InspectionTree.new do
          add_text "#<a value within "

          add_inspection_of do |aliased_matcher|
            aliased_matcher.base_matcher.instance_variable_get("@delta")
          end

          add_text " of "
          add_inspection_of(&:expected)
          add_text ">"
        end
      end
    end
  end
end
