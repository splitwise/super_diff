module SuperDiff
  module ObjectInspection
    module Nodes
      class Break < Base
        def evaluate(_object, indent_level:, single_line:)
          if single_line
            immediate_value.to_s
          else
            "\n#{"  " * indent_level}"
          end
        end
      end

      register :break, Break
    end
  end
end
