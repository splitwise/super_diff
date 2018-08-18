require "patience_diff"

require_relative "collection"

module SuperDiff
  module Differs
    class Array < Collection
      def initialize(expected, actual)
        super(expected, actual)
        @sequence_matcher = PatienceDiff::SequenceMatcher.new
      end

      def fail
        diff = build_diff("[", "]") do |event|
          inspect(event[:collection][event[:index]])
        end

        <<~OUTPUT.strip
          Differing arrays.

          #{style :deleted,  "Expected: #{expected.inspect}"}
          #{style :inserted, "  Actual: #{actual.inspect}"}

          Diff:

          #{diff}
        OUTPUT
      end

      protected

      def events
        opcodes.flat_map do |code, a_start, a_end, b_start, b_end|
          if code == :delete
            (a_start..a_end).map do |index|
              {
                state: :deleted,
                index: index,
                collection: expected
              }
            end
          elsif code == :insert
            (b_start..b_end).map do |index|
              {
                state: :inserted,
                index: index,
                collection: actual
              }
            end
          else
            (b_start..b_end).map do |index|
              {
                state: :equal,
                index: index,
                collection: actual
              }
            end
          end
        end
      end

      private

      attr_reader :sequence_matcher

      def opcodes
        sequence_matcher.diff_opcodes(expected, actual)
      end
    end
  end
end
