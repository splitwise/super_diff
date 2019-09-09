module SuperDiff
  module RSpec
    module ObjectInspection
      autoload(
        :InspectorFinder,
        "super_diff/rspec/object_inspection/inspector_finder",
      )
      autoload :Inspectors, "super_diff/rspec/object_inspection/inspectors"
    end
  end
end
