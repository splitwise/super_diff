require "spec_helper"

RSpec.describe "RSpec's `respond_to` matcher" do
  describe "#description" do
    context "without any qualifiers" do
      it "returns the correct output" do
        expect(respond_to(:foo, :bar, :baz).description).to eq(
          "respond to :foo, :bar and :baz"
        )
      end
    end

    context "qualified with #with + #arguments" do
      it "returns the correct output" do
        expect(
          respond_to(:foo, :bar, :baz).with(3).arguments.description
        ).to eq("respond to :foo, :bar and :baz with 3 arguments")
      end
    end

    context "qualified with #with_keywords" do
      it "returns the correct output" do
        matcher =
          respond_to(:foo, :bar, :baz).with_keywords(:qux, :blargh, :fizz)

        expect(matcher.description).to eq(
          "respond to :foo, :bar and :baz with keywords :qux, :blargh " +
            "and :fizz"
        )
      end
    end

    context "qualified with #with_any_keywords" do
      it "returns the correct output" do
        matcher = respond_to(:foo, :bar, :baz).with_any_keywords

        expect(matcher.description).to eq(
          "respond to :foo, :bar and :baz with any keywords"
        )
      end
    end

    context "qualified with #with_unlimited_arguments" do
      it "returns the correct output" do
        matcher = respond_to(:foo, :bar, :baz).with_unlimited_arguments

        expect(matcher.description).to eq(
          "respond to :foo, :bar and :baz with unlimited arguments"
        )
      end
    end

    context "qualified with #with_any_keywords + #with_unlimited_arguments" do
      it "returns the correct output" do
        matcher =
          respond_to(
            :foo,
            :bar,
            :baz
          ).with_any_keywords.with_unlimited_arguments

        expect(matcher.description).to eq(
          "respond to :foo, :bar and :baz with any keywords and unlimited " +
            "arguments"
        )
      end
    end

    context "qualified with #with_keywords + #with_unlimited_arguments" do
      it "returns the correct output" do
        matcher =
          respond_to(:foo, :bar, :baz).with_keywords(
            :qux,
            :blargh,
            :fizz
          ).with_unlimited_arguments

        expect(matcher.description).to eq(
          "respond to :foo, :bar and :baz with keywords :qux, :blargh and " +
            ":fizz and unlimited arguments"
        )
      end
    end
  end
end
