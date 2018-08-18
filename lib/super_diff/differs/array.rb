require_relative "../operational_sequencers/array"
require_relative "../diff_formatters/array"

module SuperDiff
  module Differs
    class Array
      def self.call(expected, actual, indent:)
        new(expected, actual, indent: indent).call
      end

      def initialize(expected, actual, indent:)
        @expected = expected
        @actual = actual
        @indent = indent
      end

      def call
        DiffFormatters::Array.call(
          OperationalSequencers::Array.call(expected, actual),
          indent: indent
        )
      end

      private

      attr_reader :expected, :actual, :indent
    end
  end
end
