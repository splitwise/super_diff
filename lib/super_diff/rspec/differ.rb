module SuperDiff
  module RSpec
    module Differ
      def self.diff(actual, expected)
        diff = SuperDiff::Differ.call(
          expected,
          actual,
          extra_operational_sequencer_classes: RSpec.extra_operational_sequencer_classes,
          extra_diff_formatter_classes: RSpec.extra_diff_formatter_classes
        )
        "\n\n" + diff
      end
    end
  end
end
