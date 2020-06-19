module SuperDiff
  module ObjectInspection
    module Nodes
      class Inspection < Base
        def self.node_name
          :inspection
        end

        def self.method_name
          :add_inspection_of
        end

        def render_to_string(object)
          value =
            if block
              evaluate_block(object)
            else
              immediate_value
            end

          SuperDiff::RecursionGuard.
            guarding_recursion_of(value) do |already_seen|
              if already_seen
                SuperDiff::RecursionGuard::PLACEHOLDER
              else
                SuperDiff.inspect_object(value, as_lines: false)
              end
            end
        end

        def render_to_lines(object, type:, indentation_level:)
          value =
            if block
              evaluate_block(object)
            else
              immediate_value
            end

          SuperDiff::RecursionGuard.
            guarding_recursion_of(value) do |already_seen|
              if already_seen
                [
                  SuperDiff::Line.new(
                    type: type,
                    indentation_level: indentation_level,
                    value: SuperDiff::RecursionGuard::PLACEHOLDER,
                  ),
                ]
              else
                SuperDiff.inspect_object(
                  value,
                  as_lines: true,
                  type: type,
                  indentation_level: indentation_level,
                )
              end
            end
        end
      end
    end
  end
end
