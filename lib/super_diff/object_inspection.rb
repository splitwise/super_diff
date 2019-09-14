module SuperDiff
  module ObjectInspection
    autoload :InspectionTree, "super_diff/object_inspection/inspection_tree"
    autoload :Inspector, "super_diff/object_inspection/inspector"
    autoload :Inspectors, "super_diff/object_inspection/inspectors"
    autoload :Map, "super_diff/object_inspection/map"
    autoload :Nodes, "super_diff/object_inspection/nodes"

    class << self
      attr_accessor :map
    end

    def self.inspect(object, as_single_line:, indent_level: 0)
      Inspector.call(
        map,
        object,
        as_single_line: as_single_line,
        indent_level: indent_level,
      )
    end

    self.map = Map.new
  end
end
