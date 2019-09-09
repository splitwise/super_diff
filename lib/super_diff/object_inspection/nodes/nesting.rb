module SuperDiff
  module ObjectInspection
    module Nodes
      class Nesting < Base
        def evaluate(object, indent_level:, single_line:)
          evaluate_in_subtree(
            object,
            indent_level: indent_level + 1,
            single_line: single_line,
            &block
          )
        end
      end
    end
  end
end
