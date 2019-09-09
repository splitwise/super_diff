module SuperDiff
  module ObjectInspection
    module Nodes
      class Inspection < Base
        def evaluate(_object, indent_level:, single_line:)
          SuperDiff::ObjectInspection.inspect(
            immediate_value,
            indent_level: indent_level,
            single_line: single_line,
          )
        end
      end
    end
  end
end
