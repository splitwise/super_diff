require "spec_helper"

RSpec.describe SuperDiff, type: :unit do
  describe ".inspect_object" do
    context "given as_lines: false" do
      subject(:output) do
        described_class.inspect_object(object, as_lines: false)
      end

      context "given a simple range" do
        let(:object) { 1..5 }

        it "shows the data" do
          expect(output).to eq("1..5")
        end
      end
    end
  end
end
