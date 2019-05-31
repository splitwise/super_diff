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
          it "returns a representation of the array as a tree" do
            inspected_output = described_class.inspect_object(
              ["foo", "bar", "baz"],
              single_line: false,
            )
            expect(inspected_output).to eq(
              SuperDiff::InspectionTree.new([
                SuperDiff::InspectionTree::OpeningNode.new(
                  level: 0,
                  value: "[",
                ),
                SuperDiff::InspectionTree::MiddleNode.new(
                  level: 1,
                  value: %("foo"),
                  first_item: true,
                  last_item: false,
                ),
                SuperDiff::InspectionTree::MiddleNode.new(
                  level: 1,
                  value: %("bar"),
                  first_item: false,
                  last_item: false,
                ),
                SuperDiff::InspectionTree::MiddleNode.new(
                  level: 1,
                  value: %("baz"),
                  first_item: false,
                  last_item: true,
                ),
                SuperDiff::InspectionTree::ClosingNode.new(
                  level: 0,
                  value: "]",
                ),
              ]),
            )
          end
        end
      end

      context "containing other arrays" do
        context "given :single_line => true" do
          it "returns a representation of the array on a single line" do
            value_to_inspect = [
              "foo",
              ["bar", "baz"],
              "qux",
            ]
            inspected_output = described_class.inspect_object(
              value_to_inspect,
              single_line: true,
            )
            expect(inspected_output).to eq(%(["foo", ["bar", "baz"], "qux"]))
          end
        end

        context "given :single_line => false" do
          it "returns a representation of the array as a tree" do
            value_to_inspect = [
              "foo",
              ["bar", "baz"],
              "qux",
            ]
            inspected_output = described_class.inspect_object(
              value_to_inspect,
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
