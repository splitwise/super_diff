module SuperDiff
  module Differs
    class Base
      def self.applies_to?(value)
        raise NotImplementedError
      end

      def self.call(*args)
        new(*args).call
      end

      def initialize(
        expected,
        actual,
        indent_level:,
        index_in_collection: nil,
        extra_operational_sequencer_classes: [],
        extra_diff_formatter_classes: []
      )
        @expected = expected
        @actual = actual
        @indent_level = indent_level
        @index_in_collection = index_in_collection
        @extra_operational_sequencer_classes = extra_operational_sequencer_classes
        @extra_diff_formatter_classes = extra_diff_formatter_classes
      end

      def call
        raise NotImplementedError
      end

      protected

      attr_reader :expected, :actual, :indent_level, :index_in_collection,
        :extra_operational_sequencer_classes, :extra_diff_formatter_classes

      def indentation
        " " * (indent_level * 2)
      end
    end
  end
end
