module SuperDiff
  module ObjectInspection
    module Nodes
      class Break < Base
        def evaluate(_object, indent_level:, as_single_line:)
          if as_single_line
            immediate_value.to_s
          else
            "\n#{"  " * indent_level}"
          end
        end
      end
    end
  end
end
