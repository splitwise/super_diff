# frozen_string_literal: true

module SuperDiff
  module ActiveSupport
    module OperationTrees
      class HashWithIndifferentAccess < Core::AbstractOperationTree
        protected

        def operation_tree_flattener_class
          OperationTreeFlatteners::HashWithIndifferentAccess
        end
      end
    end
  end
end
