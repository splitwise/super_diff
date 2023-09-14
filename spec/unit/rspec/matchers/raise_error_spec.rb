require "spec_helper"

RSpec.describe "RSpec's `raise_error` matcher" do
  describe "#description" do
    context "given only an exception class" do
      it "returns the correct output" do
        expect(raise_error(RuntimeError).description).to eq(
          "raise error #<RuntimeError>"
        )
      end
    end

    context "with only a message (and assuming a RuntimeError)" do
      it "returns the correct output" do
        expect(raise_error("hell").description).to eq(
          %|raise error #<Exception "hell">|
        )
      end
    end

    context "with regular expression as message (and assuming a RuntimeError)" do
      it "returns the correct output" do
        expect(raise_error(/hell/).description).to eq(
          "raise error #<Exception /hell/>"
        )
      end
    end

    context "with both an exception and a message" do
      it "returns the correct output" do
        expect(raise_error(RuntimeError, "hell").description).to eq(
          %|raise error #<RuntimeError "hell">|
        )
      end
    end

    context "with an exception and a regular expression as message" do
      it "returns the correct output" do
        expect(raise_error(RuntimeError, /hell/).description).to eq(
          "raise error #<RuntimeError /hell/>"
        )
      end
    end

    context "with a matcher" do
      it "returns the correct output" do
        expect(raise_error(a_kind_of(RuntimeError)).description).to eq(
          "raise error #<a kind of RuntimeError>"
        )
      end
    end
  end
end
