require "spec_helper"

RSpec.describe "RSpec's `be` matcher" do
  describe "#description" do
    context "given nothing" do
      it "returns the correct output" do
        expect(be.description).to eq("be truthy")
      end
    end

    context "given an argument" do
      it "returns the correct output" do
        expect(be(:foo).description).to eq("equal :foo")
      end
    end
  end
end
