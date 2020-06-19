require "spec_helper"

RSpec.describe SuperDiff::OperationTreeFlatteners::Hash do
  context "given an empty tree" do
    it "returns a set of lines which are simply the open token and close token" do
      expect(described_class.call([])).to match([
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %({),
          collection_bookend: :open,
          complete_bookend: :open,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(}),
          collection_bookend: :close,
          complete_bookend: :close,
        ),
      ])
    end
  end

  context "given a tree of only noops" do
    it "returns a series of lines from inspecting each value, creating multiple lines upon encountering inner data structures" do
      collection = Array.new(3) { :some_value }
      operation_tree = SuperDiff::OperationTrees::Hash.new([
        double(
          :operation,
          name: :noop,
          collection: collection,
          key: :foo,
          value: "bar",
          index: 0,
        ),
        double(
          :operation,
          name: :noop,
          collection: collection,
          key: :baz,
          value: { one: "fish", two: "fish" },
          index: 1,
        ),
        double(
          :operation,
          name: :noop,
          collection: collection,
          key: :qux,
          value: "blargh",
          index: 2,
        ),
      ])

      flattened_operation_tree = described_class.call(operation_tree)

      expect(flattened_operation_tree).to match([
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %({),
          collection_bookend: :open,
          complete_bookend: :open,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: %(foo: ),
          value: %("bar"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: %(baz: ),
          value: %({),
          collection_bookend: :open,
          complete_bookend: nil,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 2,
          prefix: %(one: ),
          value: %("fish"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 2,
          prefix: %(two: ),
          value: %("fish"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %(}),
          collection_bookend: :close,
          complete_bookend: nil,
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: %(qux: ),
          value: %("blargh"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(}),
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
      operation_tree = SuperDiff::OperationTrees::Hash.new([
        double(
          :operation,
          name: :delete,
          collection: expected,
          key: :foo,
          value: "bar",
          index: 0,
        ),
        double(
          :operation,
          name: :insert,
          collection: actual,
          key: :foo,
          value: "czar",
          index: 0,
        ),
        double(
          :operation,
          name: :noop,
          collection: actual,
          key: :baz,
          value: { :one => "fish", "two" => "fish" },
          index: 1,
        ),
        double(
          :operation,
          name: :noop,
          collection: actual,
          key: :qux,
          value: "blargh",
          index: 2,
        ),
        double(
          :operation,
          name: :insert,
          collection: actual,
          key: :sing,
          value: "song",
          index: 3,
        ),
      ])

      flattened_operation_tree = described_class.call(operation_tree)

      expect(flattened_operation_tree).to match([
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %({),
          collection_bookend: :open,
          complete_bookend: :open,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :delete,
          indentation_level: 1,
          prefix: %(foo: ),
          value: %("bar"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :insert,
          indentation_level: 1,
          prefix: %(foo: ),
          value: %("czar"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: %(baz: ),
          value: %({),
          collection_bookend: :open,
          complete_bookend: nil,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 2,
          prefix: %(:one => ),
          value: %("fish"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 2,
          prefix: %("two" => ),
          value: %("fish"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %(}),
          collection_bookend: :close,
          complete_bookend: nil,
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: %(qux: ),
          value: %("blargh"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :insert,
          indentation_level: 1,
          prefix: %(sing: ),
          value: %("song"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(}),
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
      operation_tree = SuperDiff::OperationTrees::Hash.new([
        double(
          :operation,
          name: :noop,
          collection: collection,
          key: :foo,
          value: "bar",
          index: 0,
        ),
        double(
          :operation,
          name: :change,
          left_collection: collection,
          left_key: :baz,
          left_index: 1,
          right_collection: collection,
          right_key: :baz,
          right_index: 1,
          children: SuperDiff::OperationTrees::Hash.new([
            double(
              :operation,
              name: :noop,
              collection: subcollection,
              key: :one,
              value: "fish",
              index: 0,
            ),
            double(
              :operation,
              name: :delete,
              collection: subcollection,
              key: :two,
              value: "fish",
              index: 1,
            ),
            double(
              :operation,
              name: :insert,
              collection: subcollection,
              key: :blue,
              value: "fish",
              index: 1,
            ),
          ]),
        ),
        double(
          :operation,
          name: :noop,
          collection: collection,
          key: :qux,
          value: "blargh",
          index: 2,
        ),
      ])

      flattened_operation_tree = described_class.call(operation_tree)

      expect(flattened_operation_tree).to match([
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %({),
          collection_bookend: :open,
          complete_bookend: :open,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: %(foo: ),
          value: %("bar"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: %(baz: ),
          value: %({),
          collection_bookend: :open,
          complete_bookend: nil,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 2,
          prefix: %(one: ),
          value: %("fish"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :delete,
          indentation_level: 2,
          prefix: %(two: ),
          value: %("fish"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :insert,
          indentation_level: 2,
          prefix: %(blue: ),
          value: %("fish"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %(}),
          collection_bookend: :close,
          complete_bookend: nil,
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: %(qux: ),
          value: %("blargh"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(}),
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
      right_collection = Array.new(2) { :some_value }.tap do |collection|
        collection << right_collection
      end

      operation_tree = SuperDiff::OperationTrees::Hash.new([
        double(
          :operation,
          name: :noop,
          collection: right_collection,
          key: :foo,
          value: "bar",
          index: 0,
        ),
        double(
          :operation,
          name: :noop,
          collection: right_collection,
          key: :baz,
          value: "qux",
          index: 1,
        ),
        double(
          :operation,
          name: :delete,
          collection: left_collection,
          key: :blargh,
          value: "zig",
          index: 2,
        ),
        double(
          :operation,
          name: :insert,
          collection: right_collection,
          key: :blargh,
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
          value: %({),
          collection_bookend: :open,
          complete_bookend: :open,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: %(foo: ),
          value: %("bar"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: %(baz: ),
          value: %("qux"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :delete,
          indentation_level: 1,
          prefix: %(blargh: ),
          value: %("zig"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :insert,
          indentation_level: 1,
          prefix: %(blargh: ),
          value: %(∙∙∙),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(}),
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
      right_subcollection = Array.new(1) { :some_value }.tap do |coll|
        coll << right_subcollection
      end

      operation_tree = SuperDiff::OperationTrees::Hash.new([
        double(
          :operation,
          name: :noop,
          collection: collection,
          key: :foo,
          value: "bar",
          index: 0,
        ),
        double(
          :operation,
          name: :change,
          left_collection: collection,
          left_key: :baz,
          left_index: 1,
          right_collection: collection,
          right_key: :baz,
          right_index: 1,
          children: SuperDiff::OperationTrees::Hash.new([
            double(
              :operation,
              name: :noop,
              collection: right_subcollection,
              key: :one,
              value: "fish",
              index: 0,
            ),
            double(
              :operation,
              name: :delete,
              collection: left_subcollection,
              key: :two,
              value: "fish",
              index: 1,
            ),
            double(
              :operation,
              name: :insert,
              collection: right_subcollection,
              key: :two,
              value: right_subcollection,
              index: 1,
            ),
          ]),
        ),
        double(
          :operation,
          name: :noop,
          collection: collection,
          key: :qux,
          value: "blargh",
          index: 2,
        ),
      ])

      flattened_operation_tree = described_class.call(operation_tree)

      expect(flattened_operation_tree).to match([
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %({),
          collection_bookend: :open,
          complete_bookend: :open,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: %(foo: ),
          value: %("bar"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: %(baz: ),
          value: %({),
          collection_bookend: :open,
          complete_bookend: nil,
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 2,
          prefix: %(one: ),
          value: %("fish"),
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :delete,
          indentation_level: 2,
          prefix: %(two: ),
          value: %("fish"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :insert,
          indentation_level: 2,
          prefix: %(two: ),
          value: %(∙∙∙),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: "",
          value: %(}),
          collection_bookend: :close,
          complete_bookend: nil,
          add_comma: true,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 1,
          prefix: %(qux: ),
          value: %("blargh"),
          add_comma: false,
        ),
        an_object_having_attributes(
          type: :noop,
          indentation_level: 0,
          prefix: "",
          value: %(}),
          collection_bookend: :close,
          complete_bookend: :close,
          add_comma: false,
        ),
      ])
    end
  end
end
