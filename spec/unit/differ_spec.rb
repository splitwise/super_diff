require "spec_helper"

RSpec.describe SuperDiff::Differ do
  describe "#call" do
    context "given the same number" do
      it "returns an empty string" do
        output = described_class.call(expected: 1, actual: 1)

        expect(output).to eq("")
      end
    end

    context "given differing numbers" do
      it "returns a message along with a comparison" do
        actual_output = described_class.call(expected: 42, actual: 1)

        expected_output = <<~STR
          Differing numbers.

          Expected: 42
            Actual: 1
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given the same string" do
      it "returns an empty string" do
        output = described_class.call(expected: "", actual: "")

        expect(output).to eq("")
      end
    end

    context "given completely different single-line strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(expected: "foo", actual: "bar")

        expected_output = colored do |str, color|
          str << color.plain(<<~STR)
            Differing strings.

            Expected: "foo"
              Actual: "bar"

            Diff:

          STR

          str << color.line do |line|
            line << color.light_red_bg("- foo")
          end

          str << color.line do |line|
            line << color.light_green_bg("+ bar")
          end
        end

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given closely different single-line strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(expected: "foo", actual: "foobar")

        expected_output = colored do |str, color|
          str << color.plain(<<~STR)
            Differing strings.

            Expected: "foo"
              Actual: "foobar"

            Diff:

          STR

          str << color.line(color.light_red_bg("- foo"))
          str << color.line(color.light_green_bg("+ foobar"))
        end

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given completely different multi-line strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: "This is a line\nAnd that's a line\n",
          actual: "Something completely different\nAnd something else too\n"
        )

        expected_output = colored do |str, color|
          str << color.plain(<<~STR)
            Differing strings.

            Expected: "This is a line\\nAnd that's a line\\n"
              Actual: "Something completely different\\nAnd something else too\\n"

            Diff:

          STR

          str << color.line do |line|
            line << color.light_red_bg("- This is a line⏎")
          end

          str << color.line do |line|
            line << color.light_red_bg("- And that's a line⏎")
          end

          str << color.line do |line|
            line << color.light_green_bg("+ Something completely different⏎")
          end

          str << color.line do |line|
            line << color.light_green_bg("+ And something else too⏎")
          end
        end

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given the same array" do
      it "returns an empty string" do
        output = described_class.call(expected: ["foo"], actual: ["foo"])

        expect(output).to eq("")
      end
    end

    context "given two equal-length, one-dimensional arrays with differing strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["foo", "bar", "qux"],
          actual: ["foo", "baz", "qux"]
        )

        expected_output = <<~STR
          Differing arrays.

          Expected: ["foo", "bar", "qux"]
            Actual: ["foo", "baz", "qux"]

          Details:

          - *[1]: Differing strings.
            Expected: "bar"
              Actual: "baz"
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-length, one-dimensional arrays with differing numbers" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [1, 2, 3, 4],
          actual: [1, 2, 99, 4]
        )

        expected_output = <<~STR
          Differing arrays.

          Expected: [1, 2, 3, 4]
            Actual: [1, 2, 99, 4]

          Details:

          - *[2]: Differing numbers.
            Expected: 3
              Actual: 99
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-length, one-dimensional arrays with differing objects" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [:foo, SuperDiff::Test::Person.new(name: "Elliot"), :bar],
          actual: [:foo, SuperDiff::Test::Person.new(name: "Joe"), :bar],
        )

        expected_output = <<~STR
          Differing arrays.

          Expected: [:foo, #<Person name="Elliot">, :bar]
            Actual: [:foo, #<Person name="Joe">, :bar]

          Details:

          - *[1]: Differing objects.
            Expected: #<Person name="Elliot">
              Actual: #<Person name="Joe">
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has added elements" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["foo", "bar"],
          actual: ["foo", "baz", "qux", "bar"]
        )

        expected_output = <<~STR
          Differing arrays.

          Expected: ["foo", "bar"]
            Actual: ["foo", "baz", "qux", "bar"]

          Details:

          - *[? -> 1]: Actual has extra element "baz".
          - *[? -> 2]: Actual has extra element "qux".
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has missing elements" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["foo", "baz", "qux", "bar"],
          actual: ["foo", "bar"]
        )

        expected_output = <<~STR
          Differing arrays.

          Expected: ["foo", "baz", "qux", "bar"]
            Actual: ["foo", "bar"]

          Details:

          - *[1 -> ?]: Actual is missing element "baz".
          - *[2 -> ?]: Actual is missing element "qux".
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given the same hash" do
      it "returns an empty string" do
        output = described_class.call(
          expected: { foo: "bar" },
          actual: { foo: "bar" }
        )

        expect(output).to eq("")
      end
    end

    context "given two objects which == each other" do
      it "returns an empty string" do
        expected = SuperDiff::Test::Person.new(name: "Elliot")
        actual = SuperDiff::Test::Person.new(name: "Elliot")

        output = described_class.call(expected: expected, actual: actual)

        expect(output).to eq("")
      end
    end

    context "given two objects which do not == each other" do
      it "returns a message along with a comparison" do
        expected = SuperDiff::Test::Person.new(name: "Elliot")
        actual = SuperDiff::Test::Person.new(name: "Joe")

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR
          Differing objects.

          Expected: #<Person name="Elliot">
            Actual: #<Person name="Joe">
        STR

        expect(actual_output).to eq(expected_output)
      end
    end
  end

  def colored(&block)
    string = ""
    block.call(string, SuperDiff::Csi::ColorHelper)
    string
  end
end
