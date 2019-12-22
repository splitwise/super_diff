module SuperDiff
  module RSpec
    module Differs
      class ObjectHavingAttributes < SuperDiff::Differs::DefaultObject
        def self.applies_to?(expected, _actual)
          SuperDiff::RSpec.an_object_having_some_attributes?(expected)
        end

        private

        def operations
          OperationalSequencers::ObjectHavingAttributes.call(
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
