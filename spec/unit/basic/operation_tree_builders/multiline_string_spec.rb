# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SuperDiff, type: :unit do
  describe '.diff' do
    subject(:diff) { SuperDiff.diff(expected, actual) }

    let(:expected) { <<~STRING }
      This here is a string.
      It contains separate lines.
      What else can I say?
    STRING
    let(:actual) { <<~STRING }
      This here is a string.
      It contains separate lines.
      What else can I say?
    STRING

    context 'with extra blank lines in the middle of expected' do
      let(:expected) { <<~STRING }
        This here is a string.

        It contains separate lines.


        What else can I say?
      STRING

      it 'removes the extra blank lines' do
        expected_output =
          SuperDiff::Core::Helpers
          .style(color_enabled: true) do
            plain_line '  This here is a string.\\n'
            expected_line '- \\n'
            plain_line '  It contains separate lines.\\n'
            expected_line '- \\n'
            expected_line '- \\n'
            plain_line '  What else can I say?\\n'
          end
            .to_s
            .chomp
        expect(diff).to eq(expected_output)
      end
    end

    context 'with extra blank lines in the middle of actual' do
      let(:actual) { <<~STRING }
        This here is a string.

        It contains separate lines.


        What else can I say?
      STRING

      it 'adds the extra blank lines' do
        expected_output =
          SuperDiff::Core::Helpers
          .style(color_enabled: true) do
            plain_line '  This here is a string.\\n'
            actual_line '+ \\n'
            plain_line '  It contains separate lines.\\n'
            actual_line '+ \\n'
            actual_line '+ \\n'
            plain_line '  What else can I say?\\n'
          end
            .to_s
            .chomp
        expect(diff).to eq(expected_output)
      end
    end

    context 'with two trailing newlines in expected but only one in actual' do
      let(:expected) { <<~STRING }
        This here is a string.
        It contains separate lines.
        What else can I say?

      STRING

      it 'removes the trailing newline' do
        expected_output =
          SuperDiff::Core::Helpers
          .style(color_enabled: true) do
            plain_line '  This here is a string.\\n'
            plain_line '  It contains separate lines.\\n'
            plain_line '  What else can I say?\\n'
            expected_line '- \\n'
          end
            .to_s
            .chomp
        expect(diff).to eq(expected_output)
      end
    end

    context 'with one trailing newline in expected but none in actual' do
      let(:actual) { <<~STRING.chomp }
        This here is a string.
        It contains separate lines.
        What else can I say?
      STRING

      it 'removes the trailing newline' do
        expected_output =
          SuperDiff::Core::Helpers
          .style(color_enabled: true) do
            plain_line '  This here is a string.\\n'
            plain_line '  It contains separate lines.\\n'
            expected_line '- What else can I say?\\n'
            actual_line '+ What else can I say?'
          end
            .to_s
            .chomp
        expect(diff).to eq(expected_output)
      end
    end
  end
end
