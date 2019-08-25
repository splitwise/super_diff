module SuperDiff
  module RSpec
    module Differs
      class PartialObject < SuperDiff::Differs::Object
        def self.applies_to?(expected, _actual)
          SuperDiff::RSpec.partial_object?(expected)
        end

        private

        def operations
          OperationalSequencers::PartialObject.call(
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
