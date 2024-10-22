# frozen_string_literal: true

module SuperDiff
  module Basic
    module Differs
      class DefaultObject < Core::AbstractDiffer
        def self.applies_to?(expected, actual)
          expected.instance_of?(actual.class)
        end

        protected

        def operation_tree
          SuperDiff.build_operation_tree_for(
            expected,
            actual,
            extra_operation_tree_builder_classes: [
              SuperDiff::Basic::OperationTreeBuilders::DefaultObject
            ],
            raise_if_nothing_applies: true
          )
        end
      end
    end
  end
end
