require "patience_diff"

require_relative "base"

module SuperDiff
  module Differs
    class MultiLineString < Base
      def initialize(expected, actual)
        @expected = split_into_lines(expected)
        @actual = split_into_lines(actual)

        @original_expected = @expected.join
        @original_actual = @actual.join
        @sequence_matcher = PatienceDiff::SequenceMatcher.new
      end

      def fail
        <<~OUTPUT.strip
          Differing strings.

          #{style :deleted,  "Expected: #{inspect(original_expected)}"}
          #{style :inserted, "  Actual: #{inspect(original_actual)}"}

          Diff:

          #{diff}
        OUTPUT
      end

      private

      attr_reader :original_expected, :original_actual, :sequence_matcher

      def split_into_lines(str)
        str.split(/\n/).map { |line| "#{line}⏎" }
      end

      def diff
        opcodes.flat_map do |code, a_start, a_end, b_start, b_end|
          if code == :equal
            actual[b_start..b_end].map { |line| style(:normal, " #{line}") }
          elsif code == :insert
            actual[b_start..b_end].map { |line| style(:inserted, "+ #{line}") }
          else
            expected[a_start..a_end].map { |line| style(:deleted, "- #{line}") }
          end
        end.join("\n")
      end

      def opcodes
        sequence_matcher.diff_opcodes(expected, actual)
      end
    end
  end
end
