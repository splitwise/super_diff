# frozen_string_literal: true

module SuperDiff
  module Core
    module InspectionTreeNodes
      class Inspection < Base
        def self.node_name
          :inspection
        end

        def self.method_name
          :add_inspection_of
        end

        def render_to_string(object)
          value = (block ? evaluate_block(object) : immediate_value)

          RecursionGuard.guarding_recursion_of(value) do |already_seen|
            if already_seen
              RecursionGuard::PLACEHOLDER
            else
              SuperDiff.inspect_object(value, as_lines: false)
            end
          end
        end

        def render_to_lines(object, type:, indentation_level:)
          value = (block ? evaluate_block(object) : immediate_value)

          RecursionGuard.guarding_recursion_of(value) do |already_seen|
            if already_seen
              [
                SuperDiff::Core::Line.new(
                  type: type,
                  indentation_level: indentation_level,
                  value: RecursionGuard::PLACEHOLDER
                )
              ]
            else
              SuperDiff.inspect_object(
                value,
                as_lines: true,
                type: type,
                indentation_level: indentation_level
              )
            end
          end
        end
      end
    end
  end
end
