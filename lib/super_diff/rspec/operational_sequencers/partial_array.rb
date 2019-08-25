module SuperDiff
  module RSpec
    module OperationalSequencers
      class PartialArray < SuperDiff::OperationalSequencers::Array
        def self.applies_to?(expected, actual)
          SuperDiff::RSpec.partial_array?(expected) && actual.is_a?(::Array)
        end

        def initialize(expected:, actual:, **rest)
          super

          @expected = actual_with_extra_items_in_expected_at_end
        end

        private

        def actual_with_extra_items_in_expected_at_end
          actual + (expected.expecteds - actual)
        end
      end
    end
  end
end
