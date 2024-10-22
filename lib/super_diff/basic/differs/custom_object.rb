# frozen_string_literal: true

module SuperDiff
  module Basic
    module Differs
      class CustomObject < Core::AbstractDiffer
        def self.applies_to?(expected, actual)
          expected.instance_of?(actual.class) &&
            expected.respond_to?(:attributes_for_super_diff) &&
            actual.respond_to?(:attributes_for_super_diff)
        end

        protected

        def operation_tree_builder_class
          OperationTreeBuilders::CustomObject
        end
      end
    end
  end
end
