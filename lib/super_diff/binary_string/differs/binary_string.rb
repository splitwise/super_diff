# frozen_string_literal: true

module SuperDiff
  module BinaryString
    module Differs
      class BinaryString < Core::AbstractDiffer
        def self.applies_to?(expected, actual)
          SuperDiff::BinaryString.applies_to?(expected, actual)
        end

        protected

        def operation_tree_builder_class
          OperationTreeBuilders::BinaryString
        end
      end
    end
  end
end
