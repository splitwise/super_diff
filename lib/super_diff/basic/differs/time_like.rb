# frozen_string_literal: true

module SuperDiff
  module Basic
    module Differs
      class TimeLike < Core::AbstractDiffer
        def self.applies_to?(expected, actual)
          SuperDiff.time_like?(expected) && SuperDiff.time_like?(actual)
        end

        protected

        def operation_tree_builder_class
          OperationTreeBuilders::TimeLike
        end
      end
    end
  end
end
