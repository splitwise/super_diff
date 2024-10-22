# frozen_string_literal: true

module SuperDiff
  module Basic
    module OperationTreeFlatteners
      class MultilineString < Core::AbstractOperationTreeFlattener
        def build_tiered_lines
          operation_tree.map do |operation|
            Core::Line.new(
              type: operation.name,
              indentation_level: indentation_level,
              # TODO: Test that quotes and things don't get escaped but escape
              # characters do
              value:
                operation.value.inspect[1..-2].gsub('\\"', '"').gsub("\\'", "'")
            )
          end
        end
      end
    end
  end
end
