# frozen_string_literal: true

module SuperDiff
  module Basic
    module OperationTrees
      class Array < Core::AbstractOperationTree
        def self.applies_to?(value)
          value.is_a?(::Array)
        end

        protected

        def operation_tree_flattener_class
          OperationTreeFlatteners::Array
        end
      end
    end
  end
end
