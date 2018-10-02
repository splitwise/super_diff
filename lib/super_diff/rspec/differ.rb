module SuperDiff
  module RSpec
    module Differ
      def self.diff(actual, expected)
        if (
          expected != actual &&
          expected.class == actual.class &&
          !expected.is_a?(Symbol) &&
          !expected.is_a?(Integer) &&
          !(
            expected.is_a?(String) &&
            actual.is_a?(String) &&
            !expected.include?("\n") &&
            !actual.include?("\n")
          )
        )
          diff = SuperDiff::Differ.call(
            expected,
            actual,
            extra_operational_sequencer_classes: RSpec.extra_operational_sequencer_classes,
            extra_diff_formatter_classes: RSpec.extra_diff_formatter_classes,
          )
          "\n\n" + diff
        else
          ""
        end
      end
    end
  end
end
