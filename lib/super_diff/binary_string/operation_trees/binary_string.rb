# frozen_string_literal: true

module SuperDiff
  module BinaryString
    module OperationTrees
      class BinaryString < Core::AbstractOperationTree
        def self.applies_to?(value)
          SuperDiff::BinaryString.applies_to?(value)
        end

        protected

        def operation_tree_flattener_class
          OperationTreeFlatteners::BinaryString
        end
      end
    end
  end
end
