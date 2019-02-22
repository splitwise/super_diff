module SuperDiff
  module RSpec
    module OperationalSequencers
      class PartialHash < SuperDiff::OperationalSequencers::Hash
        def self.applies_to?(expected, actual)
          expected.is_a?(::RSpec::Matchers::AliasedMatcher) &&
            expected.expected.is_a?(::Hash) &&
            actual.is_a?(::Hash)
        end

        def initialize(expected:, **rest)
          super

          @expected = expected.expected
        end

        private

        def should_add_noop_operation?(key)
          !expected.include?(key) || (
            actual.include?(key) &&
            SuperDiff::Helpers.values_equal?(expected[key], actual[key])
          )
        end

        def should_add_insert_operation?(key)
          expected.include?(key) &&
            actual.include?(key) &&
            !SuperDiff::Helpers.values_equal?(expected[key], actual[key])
        end
      end
    end
  end
end
