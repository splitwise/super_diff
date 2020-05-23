module SuperDiff
  module ActiveSupport
    module OperationTreeBuilders
      class HashWithIndifferentAccess < SuperDiff::OperationTreeBuilders::Hash
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
      end
    end
  end
end
