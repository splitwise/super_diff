module SuperDiff
  module ActiveSupport
    module OperationTreeBuilders
      class HashWithIndifferentAccess < SuperDiff::OperationTreeBuilders::Hash
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

        def initialize(expected:, actual:, **rest)
          super

          if expected.is_a?(::HashWithIndifferentAccess)
            @expected = expected.to_h
            @actual = actual.transform_keys(&:to_s)
          end

          if actual.is_a?(::HashWithIndifferentAccess)
            @expected = expected.transform_keys(&:to_s)
            @actual = actual.to_h
          end
        end

        protected

        def build_operation_tree
          OperationTrees::HashWithIndifferentAccess.new([])
        end
      end
    end
  end
end
