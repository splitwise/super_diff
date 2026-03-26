# frozen_string_literal: true

require 'spec_helper'

class WordOperationTreeBuilder < SuperDiff::Core::AbstractOperationTreeBuilder
  def self.applies_to?(expected, actual)
    expected.is_a?(::String) && actual.is_a?(::String)
  end

  protected

  def unary_operations
    expected_words = expected.split
    actual_words = actual.split

    Diff::LCS.diff(expected_words, actual_words).flat_map do |change_group|
      change_group.map do |change|
        SuperDiff::Core::UnaryOperation.new(
          name: change.action == '+' ? :insert : :delete,
          collection: expected,
          key: change.position,
          index: change.position,
          value: change.element
        )
      end
    end
  end

  def build_operation_tree
    SuperDiff::Basic::OperationTrees::Array.new([])
  end

  private

  def should_compare?(_operation, _next_operation)
    false
  end
end

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

    context 'when a string operation tree builder exists' do
      around do |example|
        with_configuration(extra_operation_tree_builder_classes: SuperDiff.configuration.extra_operation_tree_builder_classes + [WordOperationTreeBuilder]) do
          example.run
        end
      end

      let(:actual) { <<~STRING }
        This here is a string.
        It contains separate lines.
        This one is different.
      STRING

      it 'does not attempt to diff each line' do
        expected_output =
          SuperDiff::Core::Helpers
          .style(color_enabled: true) do
            plain_line '  This here is a string.\\n'
            plain_line '  It contains separate lines.\\n'
            expected_line '- What else can I say?\\n'
            actual_line '+ This one is different.\\n'
          end
            .to_s
            .chomp
        expect(diff).to eq(expected_output)
      end
    end
  end
end
