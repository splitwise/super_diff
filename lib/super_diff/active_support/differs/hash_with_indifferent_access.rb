module SuperDiff
  module ActiveSupport
    module Differs
      class HashWithIndifferentAccess < SuperDiff::Differs::Hash
        def self.applies_to?(expected, actual)
          (
            expected.is_a?(::HashWithIndifferentAccess) &&
              actual.is_a?(::Hash)
          ) ||
          (
            expected.is_a?(::Hash) &&
              actual.is_a?(::HashWithIndifferentAccess)
          )
        end

        protected

        def operation_tree_builder_class
          OperationTreeBuilders::HashWithIndifferentAccess
        end
      end
    end
  end
end
