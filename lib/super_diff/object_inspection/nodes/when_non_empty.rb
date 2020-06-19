module SuperDiff
  module ObjectInspection
    module Nodes
      class WhenNonEmpty < Base
        def self.node_name
          :when_non_empty
        end

        def self.method_name
          :when_non_empty
        end

        def render_to_string(object)
          if empty?(object)
            ""
          else
            render_to_string_in_subtree(object)
          end
        end

        def render_to_lines(object, type:, indentation_level:)
          if empty?(object)
            []
          else
            render_to_lines_in_subtree(
              object,
              type: type,
              indentation_level: indentation_level,
            )
          end
        end

        private

        def empty?(object)
          if object.respond_to?(:empty?)
            object.empty?
          else
            object.instance_variables.empty?
          end
        end
      end
    end
  end
end
