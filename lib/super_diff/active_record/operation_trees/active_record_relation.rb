module SuperDiff
  module ActiveRecord
    module OperationTrees
      class ActiveRecordRelation < SuperDiff::OperationTrees::Array
        def self.applies_to?(value)
          value.is_a?(ActiveRecord::Relation)
        end

        protected

        def operation_tree_flattener_class
          OperationTreeFlatteners::ActiveRecordRelation
        end
      end
    end
  end
end
