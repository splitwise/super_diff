module SuperDiff
  module Basic
    module OperationTreeBuilders
      class RangeObject < SuperDiff::Core::AbstractOperationTreeBuilder
        def self.applies_to?(expected, actual)
          expected.is_a?(Range) && actual.is_a?(Range)
        end

        protected

        def unary_operations
          [
            Core::UnaryOperation.new(
              name: :delete,
              collection: expected.to_s,
              key: 0,
              index: 0,
              value: expected.to_s
            ),
            Core::UnaryOperation.new(
              name: :insert,
              collection: actual.to_s,
              key: 0,
              index: 0,
              value: actual.to_s
            )
          ]
        end

        def build_operation_tree
          OperationTrees::MultilineString.new([])
        end
      end
    end
  end
end
