require "spec_helper"

RSpec.describe "RSpec's `match_array` matcher" do
  describe "#description" do
    it "returns the correct output" do
      expect(match_array(%i[foo bar baz]).description).to eq(
        "match array with :foo, :bar and :baz"
      )
    end
  end
end
