module SuperDiff
  module ObjectInspection
    module Nodes
      class WhenEmpty < Base
        def self.node_name
          :when_empty
        end

        def self.method_name
          :when_empty
        end

        def render_to_string(object)
          if empty?(object)
            render_to_string_in_subtree(object)
          else
            ""
          end
        end

        def render_to_lines(object, type:, indentation_level:)
          if empty?(object)
            render_to_lines_in_subtree(
              object,
              type: type,
              indentation_level: indentation_level,
            )
          else
            []
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
