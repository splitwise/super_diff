module SuperDiff
  module RSpec
    module Differs
      class CollectionIncluding < SuperDiff::Differs::Array
        def self.applies_to?(expected, actual)
          SuperDiff::RSpec.a_collection_including_something?(expected) &&
            actual.is_a?(::Array)
        end

        private

        def operations
          OperationalSequencers::CollectionIncluding.call(
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
