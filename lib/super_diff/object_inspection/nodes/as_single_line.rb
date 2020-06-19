module SuperDiff
  module ObjectInspection
    module Nodes
      class AsSingleLine < Base
        def self.node_name
          :as_single_line
        end

        def self.method_name
          :as_single_line
        end

        def render_to_string(object)
          if block
            render_to_string_in_subtree(object)
          else
            immediate_value.to_s
          end
        end

        def render_to_lines(object, type:, indentation_level:)
          [
            SuperDiff::Line.new(
              type: type,
              indentation_level: indentation_level,
              value: render_to_string(object),
            ),
          ]
        end
      end
    end
  end
end
