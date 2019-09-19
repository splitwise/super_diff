require "spec_helper"

RSpec.describe "RSpec's `match` matcher" do
  describe "#description" do
    it "returns the correct output" do
      expect(match(:foo).description).to eq("match :foo")
    end
  end
end
