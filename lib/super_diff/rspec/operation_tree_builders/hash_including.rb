module SuperDiff
  module RSpec
    module OperationTreeBuilders
      class HashIncluding < SuperDiff::OperationTreeBuilders::Hash
        def self.applies_to?(expected, actual)
          SuperDiff::RSpec.a_hash_including_something?(expected) &&
            actual.is_a?(::Hash)
        end

        def initialize(expected:, **rest)
          super(expected: expected.expecteds.first, **rest)
        end

        private

        def should_add_noop_operation?(key)
          !expected.include?(key) || (
            actual.include?(key) &&
            expected[key] == actual[key]
          )
        end
      end
    end
  end
end
