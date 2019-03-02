module SuperDiff
  module RSpec
    module Differs
      class PartialHash < SuperDiff::Differs::Hash
        def self.applies_to?(expected, actual)
          SuperDiff::RSpec.partial_hash?(expected) && actual.is_a?(::Hash)
        end

        private

        def operations
          OperationalSequencers::PartialHash.call(
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
