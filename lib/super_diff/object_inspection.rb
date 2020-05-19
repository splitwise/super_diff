module SuperDiff
  module ObjectInspection
    autoload :InspectionTree, "super_diff/object_inspection/inspection_tree"
    autoload :Inspectors, "super_diff/object_inspection/inspectors"
    autoload :Nodes, "super_diff/object_inspection/nodes"

    def self.inspect(object, as_single_line:, indent_level: 0)
      Inspectors::Main.call(
        object,
        as_single_line: as_single_line,
        indent_level: indent_level,
      )
    end
  end
end
