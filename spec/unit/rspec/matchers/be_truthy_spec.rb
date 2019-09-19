require "spec_helper"

RSpec.describe "RSpec's `be_truthy` matcher" do
  describe "#description" do
    it "returns the correct output" do
      expect(be_truthy.description).to eq("be truthy")
    end
  end
end
