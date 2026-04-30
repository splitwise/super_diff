# frozen_string_literal: true

require 'spec_helper'
require 'super_diff/binary_string'

RSpec.describe SuperDiff::BinaryString::OperationTreeBuilders::BinaryString,
               type: :unit do
  describe 'hex dump format (xxd style)' do
    subject(:operations) do
      described_class.call(expected: expected, actual: actual)
    end

    # These tests verify output matches xxd format:
    #   $ printf 'Hello World' | xxd
    #   00000000: 4865 6c6c 6f20 576f 726c 64              Hello World
    #
    #   $ printf 'The quick brown fox jumps over the lazy dog.' | xxd
    #   00000000: 5468 6520 7175 6963 6b20 6272 6f77 6e20  The quick brown
    #   00000010: 666f 7820 6a75 6d70 7320 6f76 6572 2074  fox jumps over t
    #   00000020: 6865 206c 617a 7920 646f 672e            he lazy dog.

    context 'with a single line of data (xxd format verification)' do
      let(:expected) { 'Hello World'.b }
      let(:actual) { 'Hello World'.b }

      it 'matches xxd output format exactly' do
        expect(operations.first.value).to eq(
          '00000000: 4865 6c6c 6f20 576f 726c 64              Hello World'
        )
      end
    end

    context 'with multiple lines of data (xxd format verification)' do
      let(:expected) { 'The quick brown fox jumps over the lazy dog.'.b }
      let(:actual) { 'The quick brown fox jumps over the lazy dog.'.b }

      it 'matches xxd output format exactly' do
        ops = operations.to_a
        expect(ops[0].value).to eq(
          '00000000: 5468 6520 7175 6963 6b20 6272 6f77 6e20  The quick brown '
        )
        expect(ops[1].value).to eq(
          '00000010: 666f 7820 6a75 6d70 7320 6f76 6572 2074  fox jumps over t'
        )
        expect(ops[2].value).to eq(
          '00000020: 6865 206c 617a 7920 646f 672e            he lazy dog.'
        )
      end
    end

    context 'with binary data containing non-printable characters' do
      let(:expected) { "\x00\x01\x41\xff\xfe".b }
      let(:actual) { "\x00\x01\x41\xff\xfe".b }

      it 'formats non-printable characters as dots and preserves printable ones' do
        expect(operations.first.value).to eq(
          '00000000: 0001 41ff fe                             ..A..'
        )
      end
    end
  end
end
