# frozen_string_literal: true

module SuperDiff
  module Core
    module InspectionTreeNodes
      class AsSingleLine < Base
        def self.node_name
          :as_single_line
        end

        def self.method_name
          :as_single_line
        end

        def render_to_string(object)
          block ? render_to_string_in_subtree(object) : immediate_value.to_s
        end

        def render_to_lines(object, type:, indentation_level:)
          [
            Line.new(
              type: type,
              indentation_level: indentation_level,
              value: render_to_string(object)
            )
          ]
        end
      end
    end
  end
end
