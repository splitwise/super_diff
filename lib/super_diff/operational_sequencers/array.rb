module SuperDiff
  module OperationalSequencers
    class Array < Base
      def self.applies_to?(value)
        value.is_a?(::Array)
      end

      def initialize(*args)
        super(*args)

        @sequence_matcher = PatienceDiff::SequenceMatcher.new
      end

      protected

      def unary_operations
        opcodes.flat_map do |code, a_start, a_end, b_start, b_end|
          if code == :delete
            (a_start..a_end).map do |index|
              UnaryOperation.new(
                name: :delete,
                collection: expected,
                key: index,
                index: index,
                value: expected[index]
              )
            end
          elsif code == :insert
            (b_start..b_end).map do |index|
              UnaryOperation.new(
                name: :insert,
                collection: actual,
                key: index,
                index: index,
                value: actual[index]
              )
            end
          else
            (b_start..b_end).map do |index|
              UnaryOperation.new(
                name: :noop,
                collection: actual,
                key: index,
                index: index,
                value: actual[index]
              )
            end
          end
        end
      end

      def operation_sequence_class
        OperationSequences::Array
      end

      private

      attr_reader :sequence_matcher

      def opcodes
        sequence_matcher.diff_opcodes(expected, actual)
      end
    end
  end
end
