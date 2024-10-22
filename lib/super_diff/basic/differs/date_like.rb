# frozen_string_literal: true

module SuperDiff
  module Basic
    module Differs
      class DateLike < Core::AbstractDiffer
        def self.applies_to?(expected, actual)
          SuperDiff.date_like?(expected) && SuperDiff.date_like?(actual)
        end

        protected

        def operation_tree_builder_class
          OperationTreeBuilders::DateLike
        end
      end
    end
  end
end
