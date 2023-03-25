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
          block ? render_to_string_in_subtree(object) : immediate_value.to_s
        end

        def render_to_lines(*, **)
          []
        end
      end
    end
  end
end
