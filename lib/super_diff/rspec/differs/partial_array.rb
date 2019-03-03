module SuperDiff
  module RSpec
    module Differs
      class PartialArray < SuperDiff::Differs::Array
        def self.applies_to?(expected, actual)
          SuperDiff::RSpec.partial_array?(expected) && actual.is_a?(::Array)
        end

        private

        def operations
          OperationalSequencers::PartialArray.call(
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
