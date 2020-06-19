require "spec_helper"

RSpec.describe SuperDiff::OperationTreeFlatteners::Array do
  context "given an empty tree" do
    it "returns a set of lines which are simply the open token and close token" do
      expect(described_class.call([])).to match([
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %([),
          collection_bookend: :open,
          complete_bookend: :open,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(]),
          collection_bookend: :close,
          complete_bookend: :close,
        ),
      ])
    end
  end

  context "given a tree of only noops" do
    it "returns a series of lines from inspecting each value, creating multiple lines upon encountering inner data structures" do
      collection = Array.new(3) { :some_value }
      operation_tree = SuperDiff::OperationTrees::Array.new([
        double(
          :operation,
          name: :noop,
          collection: collection,
          value: "foo",
          index: 0,
        ),
        double(
          :operation,
          name: :noop,
          collection: collection,
          value: ["one fish", "two fish"],
          index: 1,
        ),
        double(
          :operation,
          name: :noop,
          collection: collection,
          value: "bar",
          index: 2,
        ),
      ])

      flattened_operation_tree = described_class.call(operation_tree)

      expect(flattened_operation_tree).to match([
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %([),
          collection_bookend: :open,
          complete_bookend: :open,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %("foo"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %([),
          collection_bookend: :open,
          complete_bookend: nil,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 2,
          prefix: "",
          value: %("one fish"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 2,
          prefix: "",
          value: %("two fish"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %(]),
          collection_bookend: :close,
          complete_bookend: nil,
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %("bar"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(]),
          collection_bookend: :close,
          complete_bookend: :close,
          add_comma: false,
        ),
      ])
    end
  end

  context "given a one-dimensional tree of noops, inserts, and deletes" do
    it "returns a series of lines from inspecting each value, creating multiple lines upon encountering inner data structures" do
      expected = Array.new(3) { :some_value }
      actual = Array.new(4) { :some_value }
      operation_tree = SuperDiff::OperationTrees::Array.new([
        double(
          :operation,
          name: :delete,
          collection: expected,
          value: "foo",
          index: 0,
        ),
        double(
          :operation,
          name: :insert,
          collection: actual,
          value: "zoo",
          index: 0,
        ),
        double(
          :operation,
          name: :noop,
          collection: actual,
          value: ["one fish", "two fish"],
          index: 1,
        ),
        double(
          :operation,
          name: :noop,
          collection: actual,
          value: "bar",
          index: 2,
        ),
        double(
          :operation,
          name: :insert,
          collection: actual,
          value: "baz",
          index: 3,
        ),
      ])

      flattened_operation_tree = described_class.call(operation_tree)

      expect(flattened_operation_tree).to match([
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %([),
          collection_bookend: :open,
          complete_bookend: :open,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :delete,
          indentation_level: 1,
          prefix: "",
          value: %("foo"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :insert,
          indentation_level: 1,
          prefix: "",
          value: %("zoo"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %([),
          collection_bookend: :open,
          complete_bookend: nil,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 2,
          prefix: "",
          value: %("one fish"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 2,
          prefix: "",
          value: %("two fish"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %(]),
          collection_bookend: :close,
          complete_bookend: nil,
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %("bar"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :insert,
          indentation_level: 1,
          prefix: "",
          value: %("baz"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(]),
          collection_bookend: :close,
          complete_bookend: :close,
          add_comma: false,
        ),
      ])
    end
  end

  context "given a multi-dimensional tree of operations" do
    it "splits change operations into multiple lines" do
      collection = Array.new(3) { :some_value }
      subcollection = Array.new(2) { :some_value }
      operation_tree = SuperDiff::OperationTrees::Array.new([
        double(
          :operation,
          name: :noop,
          collection: collection,
          value: "foo",
          index: 0,
        ),
        double(
          :operation,
          name: :change,
          left_collection: collection,
          left_index: 1,
          right_collection: collection,
          right_index: 1,
          children: SuperDiff::OperationTrees::Array.new([
            double(
              :operation,
              name: :noop,
              collection: subcollection,
              value: "one fish",
              index: 0,
            ),
            double(
              :operation,
              name: :delete,
              collection: subcollection,
              value: "two fish",
              index: 1,
            ),
            double(
              :operation,
              name: :insert,
              collection: subcollection,
              value: "blue fish",
              index: 1,
            ),
          ]),
        ),
        double(
          :operation,
          name: :noop,
          collection: collection,
          value: "bar",
          index: 2,
        ),
      ])

      flattened_operation_tree = described_class.call(operation_tree)

      expect(flattened_operation_tree).to match([
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %([),
          collection_bookend: :open,
          complete_bookend: :open,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %("foo"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %([),
          collection_bookend: :open,
          complete_bookend: nil,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 2,
          prefix: "",
          value: %("one fish"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :delete,
          indentation_level: 2,
          prefix: "",
          value: %("two fish"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :insert,
          indentation_level: 2,
          prefix: "",
          value: %("blue fish"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %(]),
          collection_bookend: :close,
          complete_bookend: nil,
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %("bar"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(]),
          collection_bookend: :close,
          complete_bookend: :close,
          add_comma: false,
        ),
      ])
    end
  end

  context "given a single-dimensional tree that contains a reference to itself" do
    it "replaces the reference with a static placeholder" do
      left_collection = Array.new(3) { :some_value }
      right_collection = Array.new(2) { :some_value }
      right_collection << right_collection

      operation_tree = SuperDiff::OperationTrees::Array.new([
        double(
          :operation,
          name: :noop,
          collection: right_collection,
          value: "foo",
          index: 0,
        ),
        double(
          :operation,
          name: :noop,
          collection: right_collection,
          value: "bar",
          index: 1,
        ),
        double(
          :operation,
          name: :delete,
          collection: left_collection,
          value: "baz",
          index: 2,
        ),
        double(
          :operation,
          name: :insert,
          collection: right_collection,
          value: right_collection,
          index: 2,
        ),
      ])

      flattened_operation_tree = described_class.call(operation_tree)

      expect(flattened_operation_tree).to match([
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %([),
          collection_bookend: :open,
          complete_bookend: :open,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %("foo"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %("bar"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :delete,
          indentation_level: 1,
          prefix: "",
          value: %("baz"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :insert,
          indentation_level: 1,
          prefix: "",
          value: %(∙∙∙),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(]),
          collection_bookend: :close,
          complete_bookend: :close,
          add_comma: false,
        ),
      ])
    end
  end

  context "given a multi-dimensional tree that contains a reference to itself in an inner level" do
    it "replaces the reference with a static placeholder" do
      collection = Array.new(3) { :some_value }
      left_subcollection = Array.new(2) { :some_value }
      right_subcollection = Array.new(1) { :some_value }
      right_subcollection << right_subcollection

      operation_tree = SuperDiff::OperationTrees::Array.new([
        double(
          :operation,
          name: :noop,
          collection: collection,
          value: "foo",
          index: 0,
        ),
        double(
          :operation,
          name: :change,
          left_collection: collection,
          left_index: 1,
          right_collection: collection,
          right_index: 1,
          children: SuperDiff::OperationTrees::Array.new([
            double(
              :operation,
              name: :noop,
              collection: right_subcollection,
              value: "bar",
              index: 0,
            ),
            double(
              :operation,
              name: :delete,
              collection: left_subcollection,
              value: "baz",
              index: 1,
            ),
            double(
              :operation,
              name: :insert,
              collection: right_subcollection,
              value: right_subcollection,
              index: 1,
            ),
          ]),
        ),
        double(
          :operation,
          name: :noop,
          collection: collection,
          value: "qux",
          index: 2,
        ),
      ])

      flattened_operation_tree = described_class.call(operation_tree)

      expect(flattened_operation_tree).to match([
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %([),
          collection_bookend: :open,
          complete_bookend: :open,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %("foo"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %([),
          collection_bookend: :open,
          complete_bookend: nil,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 2,
          prefix: "",
          value: %("bar"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :delete,
          indentation_level: 2,
          prefix: "",
          value: %("baz"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :insert,
          indentation_level: 2,
          prefix: "",
          value: %(∙∙∙),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %(]),
          collection_bookend: :close,
          complete_bookend: nil,
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %("qux"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(]),
          collection_bookend: :close,
          complete_bookend: :close,
          add_comma: false,
        ),
      ])
    end
  end
end
