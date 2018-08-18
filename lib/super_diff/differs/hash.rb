require_relative "../operational_sequencers/hash"
require_relative "../diff_formatters/hash"

module SuperDiff
  module Differs
    class Hash
      def self.call(expected, actual, indent:)
        new(expected, actual, indent: indent).call
      end

      def initialize(expected, actual, indent:)
        @expected = expected
        @actual = actual
        @indent = indent
      end

      def call
        DiffFormatters::Hash.call(
          OperationalSequencers::Hash.call(expected, actual),
          indent: indent
        )
      end

      private

      attr_reader :expected, :actual, :indent
    end
  end
end
