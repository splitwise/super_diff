module SuperDiff
  module ActiveSupport
    module OperationTrees
      class HashWithIndifferentAccess < SuperDiff::OperationTrees::Base
        protected

        def operation_tree_flattener_class
          OperationTreeFlatteners::HashWithIndifferentAccess
        end
      end
    end
  end
end
