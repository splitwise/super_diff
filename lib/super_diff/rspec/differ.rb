require_relative "differs/partial_array"
require_relative "differs/partial_hash"
require_relative "operational_sequencers/partial_array"
require_relative "operational_sequencers/partial_hash"

module SuperDiff
  module RSpec
    class Differ
      def self.diff(actual, expected)
        new(actual, expected).diff
      end

      def initialize(actual, expected)
        @actual = actual
        @expected = expected
      end

      def diff
        if worth_diffing?
          diff = SuperDiff::Differ.call(
            expected,
            actual,
            extra_classes: [
              *RSpec.extra_differ_classes,
              Differs::PartialArray,
              Differs::PartialHash,
            ],
            extra_operational_sequencer_classes: [
              *RSpec.extra_operational_sequencer_classes,
              OperationalSequencers::PartialArray,
              OperationalSequencers::PartialHash,
            ],
            extra_diff_formatter_classes: RSpec.extra_diff_formatter_classes,
          )
          "\n\n" + diff
        else
          ""
        end
      end

      private

      attr_reader :actual, :expected

      def worth_diffing?
        !comparing_equal_values? &&
          comparing_values_of_a_similar_class? &&
          !comparing_primitive_values? &&
          !comparing_singleline_strings?
      end

      def comparing_equal_values?
        expected == actual
      end

      def comparing_values_of_a_similar_class?
        comparing_values_of_the_same_class? ||
          comparing_with_a_partial_hash? ||
          comparing_with_a_partial_array?
      end

      def comparing_values_of_the_same_class?
        expected.class == actual.class
      end

      def comparing_with_a_partial_hash?
        SuperDiff::RSpec.partial_hash?(expected) && actual.is_a?(::Hash)
      end

      def comparing_with_a_partial_array?
        SuperDiff::RSpec.partial_array?(expected) && actual.is_a?(::Array)
      end

      def comparing_primitive_values?
        expected.is_a?(Symbol) || expected.is_a?(Integer)
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
