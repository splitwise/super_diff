module SuperDiff
  module OperationTreeBuilders
    class MultilineString < Base
      def self.applies_to?(expected, actual)
        expected.is_a?(::String) && actual.is_a?(::String) &&
          (expected.include?("\n") || actual.include?("\n"))
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
            add_delete_operations(a_start..a_end)
          elsif code == :insert
            add_insert_operations(b_start..b_end)
          else
            add_noop_operations(b_start..b_end)
          end
        end
      end

      def build_operation_tree
        OperationTrees::MultilineString.new([])
      end

      private

      attr_reader :sequence_matcher, :original_expected, :original_actual

      def split_into_lines(string)
        string.scan(/.+(?:\r|\n|\r\n|\Z)/)
      end

      def opcodes
        sequence_matcher.diff_opcodes(expected, actual)
      end

      def add_delete_operations(indices)
        indices.map do |index|
          Operations::UnaryOperation.new(
            name: :delete,
            collection: expected,
            key: index,
            index: index,
            value: expected[index],
          )
        end
      end

      def add_insert_operations(indices)
        indices.map do |index|
          Operations::UnaryOperation.new(
            name: :insert,
            collection: actual,
            key: index,
            index: index,
            value: actual[index],
          )
        end
      end

      def add_noop_operations(indices)
        indices.map do |index|
          Operations::UnaryOperation.new(
            name: :noop,
            collection: actual,
            key: index,
            index: index,
            value: actual[index],
          )
        end
      end
    end
  end
end
