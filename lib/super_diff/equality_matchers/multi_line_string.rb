module SuperDiff
  module EqualityMatchers
    class MultiLineString < Base
      def self.applies_to?(value)
        value.class == ::String && value.include?("\n")
      end

      def initialize(
        expected:,
        actual:,
        extra_operational_sequencer_classes:,
        extra_diff_formatter_classes:
      )
        @expected = split_into_lines(expected)
        @actual = split_into_lines(actual)

        @original_expected = @expected.join
        @original_actual = @actual.join
      end

      def fail
        <<~OUTPUT.strip
          Differing strings.

          #{
            Helpers.style(
              :deleted,
              "Expected: #{Helpers.inspect_object(original_expected)}"
            )
          }
          #{
            Helpers.style(
              :inserted,
              "  Actual: #{Helpers.inspect_object(original_actual)}"
            )
          }

          Diff:

          #{diff}
        OUTPUT
      end

      private

      attr_reader :original_expected, :original_actual

      def split_into_lines(str)
        str.split(/(\n)/).map { |v| v.tr("\n", "⏎") }.each_slice(2).map(&:join)
      end

      def diff
        DiffFormatters::MultiLineString.call(operations, indent_level: 0)
      end

      def operations
        OperationalSequencers::Array.call(expected: expected, actual: actual)
      end
    end
  end
end
