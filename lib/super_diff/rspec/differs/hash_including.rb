module SuperDiff
  module RSpec
    module Differs
      class HashIncluding < SuperDiff::Differs::Hash
        def self.applies_to?(expected, actual)
          SuperDiff::RSpec.a_hash_including_something?(expected) &&
            actual.is_a?(::Hash)
        end

        private

        def operations
          OperationalSequencers::HashIncluding.call(
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
