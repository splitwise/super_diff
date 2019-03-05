require "spec_helper"

RSpec.describe SuperDiff::Helpers do
  describe ".inspect_object" do
    context "given an array" do
      context "of primitive values" do
        context "given :single_line => true" do
          it "returns a representation of the array on a single line" do
            inspected_output = described_class.inspect_object(
              ["foo", "bar", "baz"],
              single_line: true,
            )
            expect(inspected_output).to eq(%(["foo", "bar", "baz"]))
          end
        end

        context "given :single_line => false" do
          it "returns a representation of the array as a list of lines" do
            inspected_output = described_class.inspect_object(
              ["foo", "bar", "baz"],
              single_line: false,
            )
            expect(inspected_output).to eq(
              SuperDiff::InspectionTree.new([
                {
                  level: 0,
                  location: "opening",
                  value: "[",
                },
                {
                  level: 1,
                  location: "middle",
                  value: %("foo"),
                  first_item: true,
                  last_item: false,
                },
                {
                  level: 1,
                  location: "middle",
                  value: %("bar"),
                  first_item: false,
                  last_item: false,
                },
                {
                  level: 1,
                  location: "middle",
                  value: %("baz"),
                  first_item: false,
                  last_item: true,
                },
                {
                  level: 0,
                  location: "closing",
                  value: "]",
                },
              ]),
            )
          end
        end
      end
    end
  end
end
