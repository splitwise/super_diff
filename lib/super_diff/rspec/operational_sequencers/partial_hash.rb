module SuperDiff
  module RSpec
    module OperationalSequencers
      class PartialHash < SuperDiff::OperationalSequencers::Hash
        def self.applies_to?(expected, actual)
          SuperDiff::RSpec.partial_hash?(expected) && actual.is_a?(::Hash)
        end

        def initialize(expected:, **rest)
          super

          @expected = expected.expecteds.first
        end

        private

        def should_add_noop_operation?(key)
          !expected.include?(key) || (
            actual.include?(key) &&
            expected[key] == actual[key]
          )
        end

        def should_add_insert_operation?(key)
          expected.include?(key) &&
            actual.include?(key) &&
            expected[key] != actual[key]
        end
      end
    end
  end
end
