require "spec_helper"

RSpec.describe "RSpec's `eq` matcher" do
  describe "#description" do
    it "returns the correct output" do
      expect(eq(:foo).description).to eq("eq :foo")
    end
  end
end
