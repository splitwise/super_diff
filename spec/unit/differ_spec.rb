require "spec_helper"

RSpec.describe SuperDiff::Differ do
  describe "#call" do
    context "given the same integers" do
      it "returns an empty string" do
        output = described_class.call(expected: 1, actual: 1)

        expect(output).to eq("")
      end
    end

    context "given the same numbers (even if they're different types)" do
      it "returns an empty string" do
        output = described_class.call(expected: 1, actual: 1.0)

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

    context "given the same symbol" do
      it "returns an empty string" do
        output = described_class.call(expected: :foo, actual: :foo)

        expect(output).to eq("")
      end
    end

    context "given differing symbols" do
      it "returns a message along with a comparison" do
        actual_output = described_class.call(expected: :foo, actual: :bar)

        expected_output = <<~STR
          Differing symbols.

          Expected: :foo
            Actual: :bar
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
        actual_output = described_class.call(
          expected: "Marty",
          actual: "Jennifer"
        )

        expected_output = <<~STR
          Differing strings.

          Expected: "Marty"
            Actual: "Jennifer"
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given closely different single-line strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: "Marty",
          actual: "Marty McFly"
        )

        expected_output = <<~STR
          Differing strings.

          Expected: "Marty"
            Actual: "Marty McFly"
        STR

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
        output = described_class.call(
          expected: ["sausage", "egg", "cheese"],
          actual: ["sausage", "egg", "cheese"]
        )

        expect(output).to eq("")
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

    context "given two equal-length, one-dimensional arrays with differing symbols" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [:one, :fish, :two, :fish],
          actual: [:one, :FISH, :two, :fish]
        )

        expected_output = <<~STR
          Differing arrays.

          Expected: [:one, :fish, :two, :fish]
            Actual: [:one, :FISH, :two, :fish]

          Details:

          - *[1]: Differing symbols.
            Expected: :fish
              Actual: :FISH
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-length, one-dimensional arrays with differing strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["sausage", "egg", "cheese"],
          actual: ["bacon", "egg", "cheese"]
        )

        expected_output = <<~STR
          Differing arrays.

          Expected: ["sausage", "egg", "cheese"]
            Actual: ["bacon", "egg", "cheese"]

          Details:

          - *[0]: Differing strings.
            Expected: "sausage"
              Actual: "bacon"
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-length, one-dimensional arrays with differing objects" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [
            SuperDiff::Test::Person.new(name: "Marty"),
            SuperDiff::Test::Person.new(name: "Jennifer")
          ],
          actual: [
            SuperDiff::Test::Person.new(name: "Marty"),
            SuperDiff::Test::Person.new(name: "Doc")
          ],
        )

        expected_output = <<~STR
          Differing arrays.

          Expected: [#<Person name="Marty">, #<Person name="Jennifer">]
            Actual: [#<Person name="Marty">, #<Person name="Doc">]

          Details:

          - *[1]: Differing objects.
            Expected: #<Person name="Jennifer">
              Actual: #<Person name="Doc">
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has extra elements" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["bread"],
          actual: ["bread", "eggs", "milk"]
        )

        expected_output = <<~STR
          Differing arrays.

          Expected: ["bread"]
            Actual: ["bread", "eggs", "milk"]

          Details:

          - *[? -> 1]: Actual has extra element "eggs".
          - *[? -> 2]: Actual has extra element "milk".
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has missing elements" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["bread", "eggs", "milk"],
          actual: ["bread"]
        )

        expected_output = <<~STR
          Differing arrays.

          Expected: ["bread", "eggs", "milk"]
            Actual: ["bread"]

          Details:

          - *[1 -> ?]: Actual is missing element "eggs".
          - *[2 -> ?]: Actual is missing element "milk".
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given the same hash" do
      it "returns an empty string" do
        output = described_class.call(
          expected: { name: "Marty" },
          actual: { name: "Marty" }
        )

        expect(output).to eq("")
      end
    end

    context "given two equal-size, one-dimensional hashes where the same key has differing numbers" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: { tall: 12, grande: 19, venti: 20 },
          actual: { tall: 12, grande: 16, venti: 20 }
        )

        expected_output = <<~STR
          Differing hashes.

          Expected: { tall: 12, grande: 19, venti: 20 }
            Actual: { tall: 12, grande: 16, venti: 20 }

          Details:

          - *[:grande]: Differing numbers.
            Expected: 19
              Actual: 16
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the same key has differing symbols" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: { tall: :small, grande: :grand, venti: :large },
          actual: { tall: :small, grande: :medium, venti: :large },
        )

        expected_output = <<~STR
          Differing hashes.

          Expected: { tall: :small, grande: :grand, venti: :large }
            Actual: { tall: :small, grande: :medium, venti: :large }

          Details:

          - *[:grande]: Differing symbols.
            Expected: :grand
              Actual: :medium
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the same key has differing strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: { tall: "small", grande: "grand", venti: "large" },
          actual: { tall: "small", grande: "medium", venti: "large" },
        )

        expected_output = <<~STR
          Differing hashes.

          Expected: { tall: "small", grande: "grand", venti: "large" }
            Actual: { tall: "small", grande: "medium", venti: "large" }

          Details:

          - *[:grande]: Differing strings.
            Expected: "grand"
              Actual: "medium"
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the same key has differing objects" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: {
            steve: SuperDiff::Test::Person.new(name: "Jobs"),
            susan: SuperDiff::Test::Person.new(name: "Kare")
          },
          actual: {
            steve: SuperDiff::Test::Person.new(name: "Wozniak"),
            susan: SuperDiff::Test::Person.new(name: "Kare")
          }
        )

        expected_output = <<~STR
          Differing hashes.

          Expected: { steve: #<Person name="Jobs">, susan: #<Person name="Kare"> }
            Actual: { steve: #<Person name="Wozniak">, susan: #<Person name="Kare"> }

          Details:

          - *[:steve]: Differing objects.
            Expected: #<Person name="Jobs">
              Actual: #<Person name="Wozniak">
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the actual has extra keys" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: { latte: 4.5 },
          actual: { latte: 4.5, mocha: 3.5, cortado: 3 }
        )

        expected_output = <<~STR
          Differing hashes.

          Expected: { latte: 4.5 }
            Actual: { latte: 4.5, mocha: 3.5, cortado: 3 }

          Details:

          - *[? -> :mocha]: Actual has extra key (with value of 3.5).
          - *[? -> :cortado]: Actual has extra key (with value of 3).
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the actual has missing keys" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: { latte: 4.5, mocha: 3.5, cortado: 3 },
          actual: { latte: 4.5 }
        )

        expected_output = <<~STR
          Differing hashes.

          Expected: { latte: 4.5, mocha: 3.5, cortado: 3 }
            Actual: { latte: 4.5 }

          Details:

          - *[:mocha -> ?]: Actual is missing key.
          - *[:cortado -> ?]: Actual is missing key.
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two objects which == each other" do
      it "returns an empty string" do
        expected = SuperDiff::Test::Person.new(name: "Marty")
        actual = SuperDiff::Test::Person.new(name: "Marty")

        output = described_class.call(expected: expected, actual: actual)

        expect(output).to eq("")
      end
    end

    context "given two objects which do not == each other" do
      it "returns a message along with a comparison" do
        expected = SuperDiff::Test::Person.new(name: "Marty")
        actual = SuperDiff::Test::Person.new(name: "Doc")

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR
          Differing objects.

          Expected: #<Person name="Marty">
            Actual: #<Person name="Doc">
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
