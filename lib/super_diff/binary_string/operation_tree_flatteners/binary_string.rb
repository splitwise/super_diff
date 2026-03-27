# frozen_string_literal: true

module SuperDiff
  module BinaryString
    module OperationTreeFlatteners
      class BinaryString < Core::AbstractOperationTreeFlattener
        def build_tiered_lines
          operation_tree.map do |operation|
            Core::Line.new(
              type: operation.name,
              indentation_level: indentation_level,
              value: operation.value
            )
          end
        end
      end
    end
  end
end
