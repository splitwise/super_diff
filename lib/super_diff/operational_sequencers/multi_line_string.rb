module SuperDiff
  module OperationalSequencers
    class MultiLineString < Base
      def self.applies_to?(value)
        value.is_a?(::String) && value.include?("\n")
      end

      def initialize(*args)
        super(*args)

        @original_expected = @expected
        @original_actual = @actual
        @expected = split_into_lines(@expected)
        @actual = split_into_lines(@actual)
        @sequence_matcher = PatienceDiff::SequenceMatcher.new
      end

      protected

      def unary_operations
        opcodes.flat_map do |code, a_start, a_end, b_start, b_end|
          if code == :delete
            (a_start..a_end).map do |index|
              Operations::UnaryOperation.new(
                name: :delete,
                collection: expected,
                key: index,
                index: index,
                value: expected[index]
              )
            end
          elsif code == :insert
            (b_start..b_end).map do |index|
              Operations::UnaryOperation.new(
                name: :insert,
                collection: actual,
                key: index,
                index: index,
                value: actual[index]
              )
            end
          else
            (b_start..b_end).map do |index|
              Operations::UnaryOperation.new(
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

      attr_reader :sequence_matcher, :original_expected, :original_actual

      def split_into_lines(str)
        str.split(/(\n)/).map { |v| v.tr("\n", "⏎") }.each_slice(2).map(&:join)
      end

      def opcodes
        sequence_matcher.diff_opcodes(expected, actual)
      end
    end
  end
end
