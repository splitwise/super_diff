# frozen_string_literal: true

module SuperDiff
  module Basic
    module OperationTrees
      class Hash < Core::AbstractOperationTree
        def self.applies_to?(value)
          value.is_a?(::Hash)
        end

        protected

        def operation_tree_flattener_class
          OperationTreeFlatteners::Hash
        end
      end
    end
  end
end
