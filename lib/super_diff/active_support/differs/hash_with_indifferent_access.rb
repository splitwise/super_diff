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

        def call
          DiffFormatters::HashWithIndifferentAccess.call(
            operation_tree,
            indent_level: indent_level,
          )
        end

        private

        def operation_tree
          OperationTreeBuilders::HashWithIndifferentAccess.call(
            expected: expected,
            actual: actual,
          )
        end
      end
    end
  end
end
