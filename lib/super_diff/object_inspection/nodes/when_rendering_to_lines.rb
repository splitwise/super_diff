module SuperDiff
  module ObjectInspection
    module Nodes
      class WhenRenderingToLines < Base
        def self.node_name
          :when_rendering_to_lines
        end

        def self.method_name
          :when_rendering_to_lines
        end

        def render_to_string(*)
          ""
        end

        def render_to_lines(object, type:, indentation_level:)
          render_to_lines_in_subtree(
            object,
            type: type,
            indentation_level: indentation_level,
          )
        end
      end
    end
  end
end
