# frozen_string_literal: true

module SuperDiff
  module Basic
    module OperationTrees
      class MultilineString < Core::AbstractOperationTree
        def self.applies_to?(value)
          value.is_a?(::String)
        end

        protected

        def operation_tree_flattener_class
          OperationTreeFlatteners::MultilineString
        end
      end
    end
  end
end
