require "spec_helper"

RSpec.describe SuperDiff, type: :unit do
  describe ".diff" do
    subject(:diff) { described_class.diff(a, b) }

    context "when given two Range objects" do
      let(:a) { 1..5 }
      let(:b) { 5..6 }

      it "diffs their member attributes" do
        expected_output =
          SuperDiff::Core::Helpers
            .style(color_enabled: true) do
              expected_line "- 1..5"
              actual_line "+ 5..6"
            end
            .to_s
            .chomp

        expect(diff).to eq(expected_output)
      end
    end
  end
end
