module SuperDiff
  module ObjectInspection
    module Nodes
      class WhenSingleline < Base
        def evaluate(object, indent_level:, as_single_line:)
          if as_single_line
            if immediate_value
              immediate_value
            else
              evaluate_in_subtree(
                object,
                indent_level: indent_level,
                as_single_line: as_single_line,
                &block
              )
            end
          else
            ""
          end
        end
      end
    end
  end
end
