require "spec_helper"

RSpec.describe "RSpec's `contain_exactly` matcher" do
  describe "#description" do
    it "returns the correct output" do
      expect(contain_exactly(:foo, :bar, :baz).description).to eq(
        "contain exactly :foo, :bar and :baz"
      )
    end
  end
end
