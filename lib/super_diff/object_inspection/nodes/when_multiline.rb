module SuperDiff
  module ObjectInspection
    module Nodes
      class WhenMultiline < Base
        def evaluate(object, indent_level:, as_single_line:)
          if as_single_line
            ""
          elsif block
            evaluate_in_subtree(
              object,
              indent_level: indent_level,
              as_single_line: as_single_line,
              &block
            )
          else
            immediate_value
          end
        end
      end
    end
  end
end
