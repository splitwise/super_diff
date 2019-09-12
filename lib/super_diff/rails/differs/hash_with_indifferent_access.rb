module SuperDiff
  module Rails
    module Differs
      class HashWithIndifferentAccess < SuperDiff::Differs::Hash
        def self.applies_to?(expected, actual)
          (
            expected.is_a?(::HashWithIndifferentAccess) &&
              actual.is_a?(::Hash)
          ) ||
          (
            expected.is_a?(::Hash) &&
              actual.is_a?(::HashWithIndifferentAccess)
          )
        end

        def call
          DiffFormatters::HashWithIndifferentAccess.call(
            operations,
            indent_level: indent_level,
          )
        end

        private

        def operations
          OperationalSequencers::HashWithIndifferentAccess.call(
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
