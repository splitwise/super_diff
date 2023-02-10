module SuperDiff
  module ObjectInspection
    module Nodes
      class AsPrefixWhenRenderingToLines < Base
        def self.name
          :as_prefix_when_rendering_to_lines
        end

        def self.method_name
          :as_prefix_when_rendering_to_lines
        end

        def render_to_string(object)
          block ? render_to_string_in_subtree(object) : immediate_value.to_s
        end

        def render_to_lines(object, **)
          ObjectInspection::PrefixForNextNode.new(render_to_string(object))
        end
      end
    end
  end
end
