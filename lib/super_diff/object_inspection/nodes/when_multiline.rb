module SuperDiff
  module ObjectInspection
    module Nodes
      class WhenMultiline < Base
        def evaluate(object, indent_level:, single_line:)
          if single_line
            ""
          elsif block
            evaluate_in_subtree(
              object,
              indent_level: indent_level,
              single_line: single_line,
              &block
            )
          else
            immediate_value
          end
        end
      end

      register :when_multiline, WhenMultiline
    end
  end
end
