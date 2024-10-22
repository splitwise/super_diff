# frozen_string_literal: true

module SuperDiff
  module Basic
    module Differs
      class MultilineString < Core::AbstractDiffer
        def self.applies_to?(expected, actual)
          expected.is_a?(::String) && actual.is_a?(::String) &&
            (expected.include?("\n") || actual.include?("\n"))
        end

        protected

        def operation_tree_builder_class
          OperationTreeBuilders::MultilineString
        end
      end
    end
  end
end
