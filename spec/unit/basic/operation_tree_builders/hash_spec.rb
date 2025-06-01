# frozen_string_literal: true

require 'securerandom'
require 'spec_helper'

RSpec.describe SuperDiff::Basic::OperationTreeBuilders::Hash do
  describe 'the produced tree' do
    subject(:tree) { described_class.call(expected: expected, actual: actual) }

    let(:actual) do
      {
        'A' => :c,
        'B' => :x,
        'C' => :b
      }
    end

    let(:expected) do
      {
        'C' => :aaa,
        'B' => :x,
        'A' => :zzz
      }
    end

    it 'has at most two entries per key' do
      pending 'fix for issue #99'

      groups = tree.group_by(&:key)

      groups.each do |key, value|
        expect(value.count).to(be <= 2, "There are > 2 operations for key `#{key}`")
      end
    end

    context 'with large random hashes' do
      let(:operation_tree) { described_class.call(expected: expected, actual: actual) }
      let(:actual) do
        Array.new(rand(1..50)) do |i|
          [i, SecureRandom.alphanumeric(4)]
        end.to_h
      end
      let(:expected) do
        entries = actual.entries

        # Remove keys at random
        entries = entries.sample(rand(actual.length))

        # Change keys at random
        entries = entries.map do |k, v|
          [k, rand(5).zero? ? SecureRandom.alphanumeric(4) : v]
        end

        # Add keys at random
        max_key = actual.keys.max || 0
        entries += Array.new(rand(10)) do |i|
          [max_key + i + 1, SecureRandom.alphanumeric(4)]
        end

        entries.shuffle.to_h
      end

      it 'is correct' do
        (actual.keys | expected.keys).each do |key|
          relevant_operations = operation_tree.select { |op| op.key == key }

          if actual.key?(key)
            if expected.key?(key)
              if actual[key] == expected[key]
                # no-op
                expect(relevant_operations).to contain_exactly(
                  having_attributes(name: :noop)
                )
              else
                # remove, followed by add
                expect(relevant_operations).to contain_exactly(
                  having_attributes(name: :delete),
                  having_attributes(name: :insert)
                )
              end
            else
              # in actual but not expected, there should be one addition
              expect(relevant_operations).to contain_exactly(
                having_attributes(name: :insert)
              )
            end
          else
            # in expected but not actual; there should be one removal
            expect(relevant_operations).to contain_exactly(
              having_attributes(name: :delete)
            )
          end
        end
      end
    end

    context 'with expected keys interleaved with actual' do
      let(:operation_tree) { described_class.call(expected: expected, actual: actual) }

      let(:actual) do
        {
          'A' => 1,
          'C' => 3
        }
      end
      let(:expected) do
        {
          'A' => 1,
          'B' => 2,
          'C' => 3
        }
      end

      it 'interleaves the delete operation' do
        operations = operation_tree.to_a
        expect(operations.count).to eq(3)
        expect(operations[1]).to have_attributes(
          key: 'B',
          name: :delete
        )
      end
    end
  end
end
