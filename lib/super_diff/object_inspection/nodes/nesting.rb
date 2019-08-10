module SuperDiff
  module ObjectInspection
    module Nodes
      class Nesting < Base
        def evaluate(object, indent_level:, single_line:)
          subtree = InspectionTree.new(parent_tree: tree)
          subtree.instance_exec(object, &block)
          subtree.evaluate(
            object,
            single_line: single_line,
            indent_level: indent_level + 1,
          )
        end
      end

      register :nesting, Nesting
    end
  end
end
