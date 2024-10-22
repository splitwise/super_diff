# frozen_string_literal: true

module SuperDiff
  module ActiveRecord
    module OperationTreeBuilders
      class ActiveRecordRelation < Basic::OperationTreeBuilders::Array
        def self.applies_to?(expected, actual)
          expected.is_a?(::Array) && actual.is_a?(::ActiveRecord::Relation)
        end

        def initialize(actual:, **rest)
          super

          @actual = actual.to_a
        end

        private

        def operation_tree
          @operation_tree ||= OperationTrees::ActiveRecordRelation.new([])
        end
      end
    end
  end
end
