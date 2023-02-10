require "spec_helper"

RSpec.describe "RSpec's `have_<predicate>` matcher" do
  describe "#description" do
    context "given nothing" do
      it "returns the correct output" do
        expect(have_experience.description).to eq(
          "return true for `has_experience?`"
        )
      end
    end

    context "given an argument" do
      it "returns the correct output" do
        expect(have_ingredients(:sugar).description).to eq(
          "return true for `has_ingredients?(:sugar)`"
        )
      end
    end
  end
end
