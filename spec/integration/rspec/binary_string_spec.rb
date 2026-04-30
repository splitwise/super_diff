# frozen_string_literal: true

require 'spec_helper'
require 'super_diff/binary_string'

RSpec.describe 'Integration with binary strings', type: :integration do
  context 'when comparing two different binary strings' do
    it 'produces the correct failure message' do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          require 'super_diff/binary_string'
          actual = "Hello".b
          expected = "World".b
          expect(actual).to eq(expected)
        TEST
        program =
          make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet: 'expect(actual).to eq(expected)',
            expectation:
              proc do
                line do
                  plain 'Expected '
                  actual '<binary string (5 bytes)>'
                  plain ' to eq '
                  expected '<binary string (5 bytes)>'
                  plain '.'
                end
              end,
            diff:
              proc do
                expected_line '- 00000000: 576f 726c 64                             World'
                actual_line '+ 00000000: 4865 6c6c 6f                             Hello'
              end
          )

        expect(program).to produce_output_when_run(expected_output).in_color(
          color_enabled
        )
      end
    end
  end

  context 'when comparing binary strings spanning multiple lines' do
    it 'produces a multi-line hex dump diff' do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          require 'super_diff/binary_string'
          actual = ("A" * 20).b
          expected = ("A" * 16 + "B" * 4).b
          expect(actual).to eq(expected)
        TEST
        program =
          make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet: 'expect(actual).to eq(expected)',
            expectation:
              proc do
                line do
                  plain 'Expected '
                  actual '<binary string (20 bytes)>'
                  plain ' to eq '
                  expected '<binary string (20 bytes)>'
                  plain '.'
                end
              end,
            diff:
              proc do
                plain_line '  00000000: 4141 4141 4141 4141 4141 4141 4141 4141  AAAAAAAAAAAAAAAA'
                expected_line '- 00000010: 4242 4242                                BBBB'
                actual_line '+ 00000010: 4141 4141                                AAAA'
              end
          )

        expect(program).to produce_output_when_run(expected_output).in_color(
          color_enabled
        )
      end
    end
  end
end
