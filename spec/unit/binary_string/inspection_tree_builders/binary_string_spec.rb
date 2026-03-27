# frozen_string_literal: true

require 'spec_helper'
require 'super_diff/binary_string'

RSpec.describe SuperDiff::BinaryString::InspectionTreeBuilders::BinaryString do
  describe '#call' do
    it 'renders byte counts for binary strings' do
      [
        ['Hello World!'.b, 12],
        [''.b, 0],
        ["\xff\xfe\x00\x01".b, 4]
      ].each do |value, bytes|
        tree = described_class.call(value)
        result = tree.render_to_string(object: value)
        expect(result).to eq("<binary string (#{bytes} bytes)>")
      end
    end
  end
end
