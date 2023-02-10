require "spec_helper"

RSpec.describe "RSpec's `have_attributes` matcher" do
  describe "#description" do
    it "returns the correct output" do
      expect(have_attributes(foo: "bar", baz: "qux").description).to eq(
        %|have attributes (foo: "bar", baz: "qux")|
      )
    end
  end
end
