# frozen_string_literal: true

require 'securerandom'
require 'spec_helper'

RSpec.describe SuperDiff::Basic::OperationTreeBuilders::Hash, type: :unit do
  describe 'the produced tree' do
    subject(:tree) { described_class.call(expected: expected, actual: actual) }

    let(:actual) do
      {
        a: 99,
        b: 2,
        c: 99
      }
    end

    let(:expected) do
      {
        c: 3,
        b: 2,
        a: 1
      }
    end

    it 'orders key operations according to actual' do
      expect(tree).to match(
        [
          having_attributes(key: :a, name: :delete, value: 1),
          having_attributes(key: :a, name: :insert, value: 99),
          having_attributes(key: :b, name: :noop, value: 2),
          having_attributes(key: :c, name: :delete, value: 3),
          having_attributes(key: :c, name: :insert, value: 99)
        ]
      )
    end

    it 'has at most two entries per key' do
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

    context 'with unmatched expected keys interleaved with actual' do
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

    context 'with differing expected values interleaved with actual' do
      let(:actual) do
        {
          a: 1,
          b: 2,
          c: 3
        }
      end
      let(:expected) do
        {
          a: 1,
          c: 99,
          b: 2
        }
      end

      it 'colocates the delete and insert operations' do
        expect(tree).to match(
          [
            having_attributes(key: :a, name: :noop),
            having_attributes(key: :b, name: :noop),
            having_attributes(key: :c, name: :delete, value: 99),
            having_attributes(key: :c, name: :insert, value: 3)
          ]
        )
      end
    end

    context 'with interleaved additions, removals, and changes' do
      let(:actual) do
        {
          a: 1,
          b: 2,
          c: 3, # added to actual
          d: 99
        }
      end
      let(:expected) do
        {
          a: 1,
          d: 4,  # 99 in actual
          z: 26, # missing from actual
          b: 2
        }
      end

      it 'no-ops, removes, and inserts as expected' do
        expect(tree).to match(
          [
            having_attributes(key: :a, name: :noop),
            having_attributes(key: :z, name: :delete, value: 26), # missing from actual
            having_attributes(key: :b, name: :noop, value: 2),
            having_attributes(key: :c, name: :insert, value: 3),  # missing from expected
            having_attributes(key: :d, name: :delete, value: 4),
            having_attributes(key: :d, name: :insert, value: 99)
          ]
        )
      end
    end

    context 'with unmatched expected keys preceding and proceeding an actual match' do
      let(:expected) do
        {
          z: 26,
          a: 1,
          b: 2
        }
      end
      let(:actual) do
        {
          a: 1
        }
      end

      it 'appends all insert operations at the end' do
        expect(tree).to match(
          [
            having_attributes(key: :z, name: :delete, value: 26),
            having_attributes(key: :a, name: :noop, value: 1),
            having_attributes(key: :b, name: :delete, value: 2)
          ]
        )
      end
    end

    context 'with unmatched expected keys preceding and proceeding an actual mismatch' do
      let(:expected) do
        {
          z: 26,
          a: 1,
          b: 2
        }
      end
      let(:actual) do
        {
          a: 99
        }
      end

      it 'deletes keys in order corresponding to expected' do
        expect(tree).to match(
          [
            having_attributes(key: :z, name: :delete),
            having_attributes(key: :a, name: :delete, value: 1),
            having_attributes(key: :a, name: :insert, value: 99),
            having_attributes(key: :b, name: :delete)
          ]
        )
      end
    end

    context 'with a changed value whose key in expected precedes a match and whose key in actual proceeds the match' do
      let(:expected) do
        {
          b: 2,
          a: 1
        }
      end
      let(:actual) do
        {
          a: 1,
          b: 99
        }
      end

      it 'colocates the insert and delete according to actual key order' do
        expect(tree).to match(
          [
            having_attributes(key: :a, name: :noop),
            having_attributes(key: :b, name: :delete, value: 2),
            having_attributes(key: :b, name: :insert, value: 99)
          ]
        )
      end
    end

    context 'when the last actual value mismatches and the expected key precedes the last match' do
      let(:actual) do
        {
          c: 1,
          b: 2,
          a: 3
        }
      end
      let(:expected) do
        {
          a: 1,
          b: 2,
          c: 3
        }
      end

      it 'constructs the correct operation tree' do
        expect(tree).to match(
          [
            having_attributes(key: :c, name: :delete, value: 3),
            having_attributes(key: :c, name: :insert, value: 1),
            having_attributes(key: :b, name: :noop, value: 2),
            having_attributes(key: :a, name: :delete, value: 1),
            having_attributes(key: :a, name: :insert, value: 3)
          ]
        )
      end
    end
  end
end
