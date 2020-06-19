module SuperDiff
  module ObjectInspection
    module Nodes
      class WhenRenderingToString < Base
        def self.node_name
          :when_rendering_to_string
        end

        def self.method_name
          :when_rendering_to_string
        end

        def render_to_string(object)
          if block
            render_to_string_in_subtree(object)
          else
            immediate_value.to_s
          end
        end

        def render_to_lines(*, **)
          []
        end
      end
    end
  end
end
