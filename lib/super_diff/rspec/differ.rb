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
            extra_classes: [
              *RSpec.configuration.extra_differ_classes,
              Differs::CollectionContainingExactly,
              Differs::PartialArray,
              Differs::PartialHash,
              Differs::PartialObject,
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
      end

      private

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
          comparing_with_a_partial_array? ||
          comparing_with_a_partial_object? ||
          comparing_with_a_collection_containing_exactly?
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

      def comparing_with_a_partial_object?
        SuperDiff::RSpec.partial_object?(expected)
      end

      def comparing_with_a_collection_containing_exactly?
        SuperDiff::RSpec.collection_containing_exactly?(expected)
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
