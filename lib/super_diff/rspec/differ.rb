module SuperDiff
  module RSpec
    class Differ
      extend AttrExtras.mixin

      static_facade :diff, :actual, :expected

      def diff
        if worth_diffing?
          diff = SuperDiff::Differ.call(
            expected,
            actual,
            omit_empty: true,
            extra_classes: [
              *RSpec.configuration.extra_differ_classes,
              Differs::CollectionContainingExactly,
              Differs::PartialArray,
              Differs::PartialHash,
              # Differs::PartialObject,
            ],
            extra_operational_sequencer_classes: [
              *RSpec.configuration.extra_operational_sequencer_classes,
              OperationalSequencers::CollectionContainingExactly,
              OperationalSequencers::PartialArray,
              OperationalSequencers::PartialHash,
              OperationalSequencers::PartialObject,
            ],
            extra_diff_formatter_classes: RSpec.configuration.extra_diff_formatter_classes,
          )
          "\n\n" + diff
        else
          ""
        end
      rescue NoDifferAvailableError
        ""
      end

      private

      def worth_diffing?
        comparing_inequal_values? &&
          !comparing_primitive_values? &&
          !comparing_singleline_strings?
      end

      def comparing_inequal_values?
        expected != actual
      end

      def comparing_primitive_values?
        expected.is_a?(Symbol) ||
          expected.is_a?(Integer) ||
          [true, false, nil].include?(expected)
      end

      def comparing_singleline_strings?
        expected.is_a?(String) &&
          actual.is_a?(String) &&
          !expected.include?("\n") &&
          !actual.include?("\n")
      end
    end
  end
end
