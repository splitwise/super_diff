# frozen_string_literal: true

module SuperDiff
  module BinaryString
    module OperationTreeBuilders
      class BinaryString < Basic::OperationTreeBuilders::MultilineString
        BYTES_PER_LINE = 16
        private_constant :BYTES_PER_LINE

        def self.applies_to?(expected, actual)
          SuperDiff::BinaryString.applies_to?(expected, actual)
        end

        def initialize(*args)
          args.first[:expected] = binary_to_hex(args.first[:expected])
          args.first[:actual] = binary_to_hex(args.first[:actual])

          super
        end

        protected

        def build_operation_tree
          OperationTrees::BinaryString.new([])
        end

        # Prevent creation of BinaryOperation objects which the flattener
        # cannot handle
        def should_compare?(_operation, _next_operation)
          false
        end

        private

        def split_into_lines(string)
          super.map { |line| line.delete_suffix("\n") }.reject(&:empty?)
        end

        def binary_to_hex(data)
          data
            .each_byte
            .each_slice(BYTES_PER_LINE)
            .with_index
            .map { |bytes, index| format_hex_line(index * BYTES_PER_LINE, bytes) }
            .join("\n")
        end

        def format_hex_line(offset, bytes)
          hex_pairs = bytes
                      .map { |b| format('%02x', b) }
                      .each_slice(2)
                      .map(&:join)
                      .join(' ')

          ascii = bytes.map { |b| printable_char(b) }.join

          format('%<offset>08x: %<hex>-39s  %<ascii>s', offset:, hex: hex_pairs, ascii:)
        end

        def printable_char(byte)
          byte >= 32 && byte < 127 ? byte.chr : '.'
        end
      end
    end
  end
end
