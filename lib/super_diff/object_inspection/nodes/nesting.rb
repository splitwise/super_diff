module SuperDiff
  module ObjectInspection
    module Nodes
      class Nesting < Base
        def self.node_name
          :nesting
        end

        def self.method_name
          :nested
        end

        def render_to_string(object)
          render_to_string_in_subtree(object)
        end

        def render_to_lines(object, type:, indentation_level:)
          render_to_lines_in_subtree(
            object,
            type: type,
            indentation_level: indentation_level + 1,
          )
        end
      end
    end
  end
end
