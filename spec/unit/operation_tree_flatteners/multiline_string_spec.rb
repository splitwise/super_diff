require "spec_helper"

RSpec.describe SuperDiff::OperationTreeFlatteners::MultilineString do
  context "given an empty tree" do
    it "returns an empty set of lines" do
      operation_tree = SuperDiff::OperationTrees::MultilineString.new([])
      flattened_operation_tree = described_class.call(operation_tree)
      expect(flattened_operation_tree).to eq([])
    end
  end

  context "given a tree of only noops" do
    it "returns a series of lines from printing each value" do
      collection = Array.new(3) { :some_value }
      operation_tree = SuperDiff::OperationTrees::MultilineString.new([
        double(
          :operation,
          name: :noop,
          collection: collection,
          value: "This is a line\n",
          index: 0,
        ),
        double(
          :operation,
          name: :noop,
          collection: collection,
          value: "This is another line\n",
          index: 1,
        ),
        double(
          :operation,
          name: :noop,
          collection: collection,
          value: "This is yet another line",
          index: 2,
        ),
      ])

      flattened_operation_tree = described_class.call(operation_tree)

      expect(flattened_operation_tree).to match([
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(This is a line\\n),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(This is another line\\n),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(This is yet another line),
          add_comma: false,
        ),
      ])
    end
  end

  context "given a tree of noops, inserts, and deletes" do
    it "returns a series of lines from printing each value" do
      collection = Array.new(3) { :some_value }
      operation_tree = SuperDiff::OperationTrees::MultilineString.new([
        double(
          :operation,
          name: :noop,
          collection: collection,
          value: "This is a line\n",
          index: 0,
        ),
        double(
          :operation,
          name: :delete,
          collection: collection,
          value: "This is another line\n",
          index: 1,
        ),
        double(
          :operation,
          name: :insert,
          collection: collection,
          value: "This is yet another line",
          index: 1,
        ),
      ])

      flattened_operation_tree = described_class.call(operation_tree)

      expect(flattened_operation_tree).to match([
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(This is a line\\n),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :delete,
          indentation_level: 0,
          prefix: "",
          value: %(This is another line\\n),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :insert,
          indentation_level: 0,
          prefix: "",
          value: %(This is yet another line),
          add_comma: false,
        ),
      ])
    end
  end
end
