require "spec_helper"

RSpec.describe "RSpec's `be_nil` matcher" do
  describe "#description" do
    it "returns the correct output" do
      expect(be_nil.description).to eq("be nil")
    end
  end
end
