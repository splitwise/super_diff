require "spec_helper"

RSpec.describe SuperDiff::Helpers do
  describe ".inspect_object" do
    context "given an array" do
      context "containing only primitive values" do
        context "given :single_line => true" do
          it "returns a representation of the array on a single line" do
            inspected_output = described_class.inspect_object(
              ["foo", 2, "baz"],
              single_line: true,
            )
            expect(inspected_output).to eq(%(["foo", 2, "baz"]))
          end
        end

        context "given :single_line => false" do
          it "returns a representation of the array as a tree" do
            inspected_output = described_class.inspect_object(
              ["foo", 2, "baz"],
              single_line: false,
            )
            expect(inspected_output).to eq(
              SuperDiff::Inspection::Tree.new([
                SuperDiff::Inspection::OpeningNode.new(
                  level: 0,
                  value: "[",
                ),
                SuperDiff::Inspection::MiddleNode.new(
                  level: 1,
                  value: %("foo"),
                  first_item_in_middle: true,
                  last_item_in_middle: false,
                ),
                SuperDiff::Inspection::MiddleNode.new(
                  level: 1,
                  value: %(2),
                  first_item_in_middle: false,
                  last_item_in_middle: false,
                ),
                SuperDiff::Inspection::MiddleNode.new(
                  level: 1,
                  value: %("baz"),
                  first_item_in_middle: false,
                  last_item_in_middle: true,
                ),
                SuperDiff::Inspection::ClosingNode.new(
                  level: 0,
                  value: "]",
                ),
              ]),
            )
          end
        end
      end

      context "containing other arrays" do
        context "given single_line: true" do
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

        context "given single_line: false" do
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
              SuperDiff::Inspection::Tree.new([
                SuperDiff::Inspection::OpeningNode.new(
                  level: 0,
                  value: "[",
                ),
                SuperDiff::Inspection::MiddleNode.new(
                  level: 1,
                  value: %("foo"),
                  first_item_in_middle: true,
                  last_item_in_middle: false,
                ),
                SuperDiff::Inspection::OpeningNode.new(
                  level: 1,
                  value: "[",
                ),
                SuperDiff::Inspection::MiddleNode.new(
                  level: 2,
                  value: %("bar"),
                  first_item_in_middle: true,
                  last_item_in_middle: false,
                ),
                SuperDiff::Inspection::MiddleNode.new(
                  level: 2,
                  value: %("baz"),
                  first_item_in_middle: false,
                  last_item_in_middle: true,
                ),
                SuperDiff::Inspection::ClosingNode.new(
                  level: 1,
                  value: "]",
                ),
                SuperDiff::Inspection::MiddleNode.new(
                  level: 1,
                  value: %("qux"),
                  first_item_in_middle: false,
                  last_item_in_middle: true,
                ),
                SuperDiff::Inspection::ClosingNode.new(
                  level: 0,
                  value: "]",
                ),
              ]),
            )
          end
        end
      end
    end

    context "given a hash" do
      context "containing only primitive values" do
        context "given :single_line => true" do
          it "returns a representation of the hash on a single line" do
            inspected_output = described_class.inspect_object(
              { :foo => "bar", 2 => "baz" },
              single_line: true,
            )
            expect(inspected_output).to eq(%({ foo: "bar", 2 => "baz" }))
          end
        end

        context "given :single_line => false" do
          it "returns a representation of the hash as a tree" do
            inspected_output = described_class.inspect_object(
              { :foo => "bar", 2 => "baz" },
              single_line: false,
            )
            expect(inspected_output).to eq(
              SuperDiff::Inspection::Tree.new([
                SuperDiff::Inspection::OpeningNode.new(
                  level: 0,
                  value: "{",
                ),
                SuperDiff::Inspection::MiddleNode.new(
                  level: 1,
                  prefix: %(foo: ),
                  value: %("bar"),
                  first_item_in_middle: true,
                  last_item_in_middle: false,
                ),
                SuperDiff::Inspection::MiddleNode.new(
                  level: 1,
                  prefix: %(2 => ),
                  value: %("baz"),
                  first_item_in_middle: false,
                  last_item_in_middle: true,
                ),
                SuperDiff::Inspection::ClosingNode.new(
                  level: 0,
                  value: "}",
                ),
              ]),
            )
          end
        end
      end

      context "containing other hashes" do
        context "given single_line: true" do
          it "returns a representation of the hash on a single line" do
            value_to_inspect = {
              products_by_sku: {
                "EMDL-2934" => { id: 4, name: "Jordan Air" },
                "KDS-3912" => { id: 8, name: "Chevy Impala" },
              },
            }
            inspected_output = described_class.inspect_object(
              value_to_inspect,
              single_line: true,
            )
            # rubocop:disable Metrics/LineLength
            expect(inspected_output).to eq(
              %({ products_by_sku: { "EMDL-2934" => { id: 4, name: "Jordan Air" }, "KDS-3912" => { id: 8, name: "Chevy Impala" } } }),
            )
            # rubocop:enable Metrics/LineLength
          end
        end

        context "given single_line: false" do
          it "returns a representation of the array as a tree" do
            value_to_inspect = {
              category_name: "Appliances",
              products_by_sku: {
                "EMDL-2934" => { id: 4, name: "George Foreman Grill" },
                "KDS-3912" => { id: 8, name: "Magic Bullet" },
              },
            }
            inspected_output = described_class.inspect_object(
              value_to_inspect,
              single_line: false,
            )
            expect(inspected_output).to eq(
              SuperDiff::Inspection::Tree.new([
                SuperDiff::Inspection::OpeningNode.new(
                  level: 0,
                  value: "{",
                ),
                SuperDiff::Inspection::MiddleNode.new(
                  level: 1,
                  prefix: %(category_name: ),
                  value: %("Appliances"),
                  first_item_in_middle: true,
                  last_item_in_middle: false,
                ),
                SuperDiff::Inspection::OpeningNode.new(
                  level: 1,
                  prefix: %(products_by_sku: ),
                  value: "{",
                ),
                SuperDiff::Inspection::OpeningNode.new(
                  level: 2,
                  prefix: %("EMDL-2934" => ),
                  value: "{",
                ),
                SuperDiff::Inspection::MiddleNode.new(
                  level: 3,
                  prefix: %(id: ),
                  value: %(4),
                  first_item_in_middle: true,
                  last_item_in_middle: false,
                ),
                SuperDiff::Inspection::MiddleNode.new(
                  level: 3,
                  prefix: %(name: ),
                  value: %("George Foreman Grill"),
                  first_item_in_middle: false,
                  last_item_in_middle: true,
                ),
                SuperDiff::Inspection::ClosingNode.new(
                  level: 2,
                  value: "}",
                ),
                SuperDiff::Inspection::OpeningNode.new(
                  level: 2,
                  prefix: %("KDS-3912" => ),
                  value: "{",
                ),
                SuperDiff::Inspection::MiddleNode.new(
                  level: 3,
                  prefix: %(id: ),
                  value: %(8),
                  first_item_in_middle: true,
                  last_item_in_middle: false,
                ),
                SuperDiff::Inspection::MiddleNode.new(
                  level: 3,
                  prefix: %(name: ),
                  value: %("Magic Bullet"),
                  first_item_in_middle: false,
                  last_item_in_middle: true,
                ),
                SuperDiff::Inspection::ClosingNode.new(
                  level: 2,
                  value: "}",
                ),
                SuperDiff::Inspection::ClosingNode.new(
                  level: 1,
                  value: "}",
                ),
                SuperDiff::Inspection::ClosingNode.new(
                  level: 0,
                  value: "}",
                ),
              ]),
            )
          end
        end
      end
    end
  end
end
