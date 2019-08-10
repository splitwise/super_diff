module SuperDiff
  module ObjectInspection
    module Nodes
      class Break < Base
        def evaluate(_object, indent_level:, single_line:)
          if single_line
            immediate_value.to_s
          else
            "\n#{tree.line_prefix}#{"  " * indent_level}"
          end
        end
      end

      register :break, Break
    end
  end
end
