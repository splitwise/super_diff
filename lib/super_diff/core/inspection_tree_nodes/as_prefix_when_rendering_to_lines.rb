# frozen_string_literal: true

module SuperDiff
  module Core
    module InspectionTreeNodes
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
          PrefixForNextInspectionTreeNode.new(render_to_string(object))
        end
      end
    end
  end
end
