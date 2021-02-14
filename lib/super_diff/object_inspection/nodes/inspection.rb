module SuperDiff
  module ObjectInspection
    module Nodes
      class Inspection < Base
        def evaluate(object, indent_level:, as_single_line:)
          value =
            if block
              tree.evaluate_block(object, &block)
            else
              immediate_value
            end

          SuperDiff.inspect_object(
            value,
            indent_level: indent_level,
            as_single_line: as_single_line,
          )
        end
      end
    end
  end
end
