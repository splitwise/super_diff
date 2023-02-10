module SuperDiff
  module RSpec
    module OperationTreeBuilders
      class HashIncluding < SuperDiff::OperationTreeBuilders::Hash
        include ::RSpec::Matchers::Composable

        def self.applies_to?(expected, actual)
          (
            SuperDiff::RSpec.a_hash_including_something?(expected) ||
              SuperDiff::RSpec.hash_including_something?(expected)
          ) && actual.is_a?(::Hash)
        end

        def initialize(expected:, **rest)
          hash =
            if SuperDiff::RSpec.a_hash_including_something?(expected)
              expected.expecteds.first
            else
              expected.instance_variable_get(:@expected)
            end
          super(expected: hash, **rest)
        end

        private

        def should_add_noop_operation?(key)
          !expected.include?(key) ||
            (actual.include?(key) && values_match?(expected[key], actual[key]))
        end
      end
    end
  end
end
