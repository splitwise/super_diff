module SuperDiff
  module ObjectInspection
    module Nodes
      class Nesting < Base
        def evaluate(object, indent_level:, as_single_line:)
          evaluate_in_subtree(
            object,
            indent_level: indent_level + 1,
            as_single_line: as_single_line,
            &block
          )
        end
      end
    end
  end
end
