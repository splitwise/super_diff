require_relative "../operational_sequencers/array"
require_relative "../diff_formatters/multi_line_string"
require_relative "base"

module SuperDiff
  module EqualityMatchers
    class MultiLineString < Base
      def initialize(expected, actual)
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
        DiffFormatters::MultiLineString.call(operations, indent: 0)
      end

      def operations
        OperationalSequencers::Array.call(expected, actual)
      end
    end
  end
end
