module SuperDiff
  module Basic
    module Differs
      class RangeObject < Core::AbstractDiffer
        def self.applies_to?(expected, actual)
          expected.is_a?(Range) && actual.is_a?(Range)
        end

        protected

        def operation_tree_builder_class
          OperationTreeBuilders::RangeObject
        end
      end
    end
  end
end
