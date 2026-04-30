# frozen_string_literal: true

require 'spec_helper'
require 'super_diff/binary_string'

RSpec.describe SuperDiff::BinaryString::OperationTreeFlatteners::BinaryString do
  it 'returns a series of lines from printing each value' do
    collection = Array.new(3) { :some_value }
    cases = [
      {
        operations: [],
        expected: []
      },
      {
        operations: [
          operation_double(
            collection,
            name: :noop,
            value: '00000000: 4865 6c6c 6f                             Hello',
            index: 0
          ),
          operation_double(
            collection,
            name: :noop,
            value: '00000010: 576f 726c 64                             World',
            index: 1
          )
        ],
        expected: [
          line_matcher(
            type: :noop,
            value: '00000000: 4865 6c6c 6f                             Hello'
          ),
          line_matcher(
            type: :noop,
            value: '00000010: 576f 726c 64                             World'
          )
        ]
      },
      {
        operations: [
          operation_double(
            collection,
            name: :noop,
            value: '00000000: 4865 6c6c 6f                             Hello',
            index: 0
          ),
          operation_double(
            collection,
            name: :delete,
            value: '00000010: 4141 4141 41                             AAAAA',
            index: 1
          ),
          operation_double(
            collection,
            name: :insert,
            value: '00000010: 4242 4242 42                             BBBBB',
            index: 1
          )
        ],
        expected: [
          line_matcher(
            type: :noop,
            value: '00000000: 4865 6c6c 6f                             Hello'
          ),
          line_matcher(
            type: :delete,
            value: '00000010: 4141 4141 41                             AAAAA'
          ),
          line_matcher(
            type: :insert,
            value: '00000010: 4242 4242 42                             BBBBB'
          )
        ]
      }
    ]

    cases.each do |spec|
      operation_tree =
        SuperDiff::BinaryString::OperationTrees::BinaryString.new(
          spec[:operations]
        )
      flattened_operation_tree = described_class.call(operation_tree)

      expect(flattened_operation_tree).to match(spec[:expected])
    end
  end

  def operation_double(collection, name:, value:, index:)
    double(
      :operation,
      name: name,
      collection: collection,
      value: value,
      index: index
    )
  end

  def line_matcher(type:, value:)
    an_object_having_attributes(
      type: type,
      indentation_level: 0,
      prefix: '',
      value: value,
      add_comma: false
    )
  end
end
