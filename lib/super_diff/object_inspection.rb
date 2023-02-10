module SuperDiff
  module ObjectInspection
    autoload :InspectionTree, "super_diff/object_inspection/inspection_tree"
    autoload(
      :InspectionTreeBuilders,
      "super_diff/object_inspection/inspection_tree_builders"
    )
    autoload :Nodes, "super_diff/object_inspection/nodes"
    autoload(
      :PrefixForNextNode,
      "super_diff/object_inspection/prefix_for_next_node"
    )
    autoload(
      :PreludeForNextNode,
      "super_diff/object_inspection/prelude_for_next_node"
    )
  end
end
