# frozen_string_literal: true

module SuperDiff
  module ActiveRecord
    module Differs
      class ActiveRecordRelation < Core::AbstractDiffer
        def self.applies_to?(expected, actual)
          expected.is_a?(::Array) && actual.is_a?(::ActiveRecord::Relation)
        end

        protected

        def operation_tree_builder_class
          OperationTreeBuilders::ActiveRecordRelation
        end
      end
    end
  end
end
