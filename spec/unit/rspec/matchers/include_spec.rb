require "spec_helper"

RSpec.describe "RSpec's `include` matcher" do
  describe "#description" do
    context "given a list of items" do
      it "returns the correct output" do
        expect(include(:foo, :bar, :baz).description).to eq(
          "include :foo, :bar, and :baz"
        )
      end
    end

    context "given a hash" do
      it "returns the correct output" do
        expect(include(foo: "bar", baz: "qux").description).to eq(
          'include (foo: "bar", baz: "qux")'
        )
      end
    end
  end
end
