module SuperDiff
  module RSpec
    module Differs
      class CollectionContainingExactly < SuperDiff::Differs::Array
        def self.applies_to?(expected, actual)
          SuperDiff::RSpec.a_collection_containing_exactly_something?(expected) &&
            actual.is_a?(::Array)
        end

        private

        def operations
          OperationalSequencers::CollectionContainingExactly.call(
            expected: expected,
            actual: actual,
            extra_operational_sequencer_classes: extra_operational_sequencer_classes,
            extra_diff_formatter_classes: extra_diff_formatter_classes,
          )
        end
      end
    end
  end
end
