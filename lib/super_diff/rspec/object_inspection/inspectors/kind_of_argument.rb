module SuperDiff
  module RSpec
    module ObjectInspection
      module Inspectors
        KindOfArgument =
          SuperDiff::ObjectInspection::InspectionTree.new do
            add_text do |matcher|
              "(kind of #{matcher.instance_variable_get("@klass")})"
            end
          end
      end
    end
  end
end
