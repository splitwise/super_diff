module SuperDiff
  module ObjectInspection
    autoload :InspectionTree, "super_diff/object_inspection/inspection_tree"
    autoload(
      :InspectorFinder,
      "super_diff/object_inspection/inspector_finder",
    )
    autoload :Inspectors, "super_diff/object_inspection/inspectors"
    autoload :Nodes, "super_diff/object_inspection/nodes"

    class << self
      attr_accessor :inspector_finder
    end

    def self.inspect(object, single_line:, indent_level: 0)
      inspector_finder.call(object).evaluate(
        object,
        single_line: single_line,
        indent_level: indent_level,
      )
    end

    self.inspector_finder = InspectorFinder
  end
end
