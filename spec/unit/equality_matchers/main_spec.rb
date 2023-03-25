require "spec_helper"

RSpec.describe SuperDiff::EqualityMatchers::Main, type: :unit do
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

        expected_output = <<~STR.strip
          Differing numbers.

          #{
          colored do
            expected_line "Expected: 42"
            actual_line "  Actual: 1"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
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

        expected_output = <<~STR.strip
          Differing symbols.

          #{
          colored do
            expected_line "Expected: :foo"
            actual_line "  Actual: :bar"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
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
        actual_output =
          described_class.call(expected: "Marty", actual: "Jennifer")

        expected_output = <<~STR.strip
          Differing strings.

          #{
          colored do
            expected_line %(Expected: "Marty")
            actual_line %(  Actual: "Jennifer")
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given closely different single-line strings" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(expected: "Marty", actual: "Marty McFly")

        expected_output = <<~STR.strip
          Differing strings.

          #{
          colored do
            expected_line %(Expected: "Marty")
            actual_line %(  Actual: "Marty McFly")
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given a single-line string and a multi-line string" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: "Something entirely different",
            actual: "This is a line\nAnd that's another line\n"
          )

        expected_output = <<~STR.strip
          Differing strings.

          #{
          colored do
            expected_line %(Expected: "Something entirely different")
            actual_line %(  Actual: "This is a line\\nAnd that's another line\\n")
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given a multi-line string and a single-line string" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: "This is a line\nAnd that's another line\n",
            actual: "Something entirely different"
          )

        expected_output = <<~STR.strip
          Differing strings.

          #{
          colored do
            expected_line %(Expected: "This is a line\\nAnd that's another line\\n")
            actual_line %(  Actual: "Something entirely different")
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given closely different multi-line strings" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected:
              "This is a line\nAnd that's a line\nAnd there's a line too",
            actual:
              "This is a line\nSomething completely different\nAnd there's a line too"
          )

        expected_output = <<~STR.strip
          Differing strings.

          #{
          colored do
            expected_line %(Expected: "This is a line\\nAnd that's a line\\nAnd there's a line too")
            actual_line %(  Actual: "This is a line\\nSomething completely different\\nAnd there's a line too")
          end
        }

          Diff:

          #{
          colored do
            plain_line %(  This is a line\\n)
            expected_line %(- And that's a line\\n)
            actual_line %(+ Something completely different\\n)
            plain_line "  And there's a line too"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given completely different multi-line strings" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: "This is a line\nAnd that's a line\n",
            actual: "Something completely different\nAnd something else too\n"
          )

        expected_output = <<~STR.strip
          Differing strings.

          #{
          colored do
            expected_line %(Expected: "This is a line\\nAnd that's a line\\n")
            actual_line %(  Actual: "Something completely different\\nAnd something else too\\n")
          end
        }

          Diff:

          #{
          colored do
            expected_line %(- This is a line\\n)
            expected_line %(- And that's a line\\n)
            actual_line %(+ Something completely different\\n)
            actual_line %(+ And something else too\\n)
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given multi-line strings that contain color codes" do
      it "escapes the color codes" do
        colors = [
          SuperDiff::Csi::FourBitColor.new(:blue, layer: :foreground),
          SuperDiff::Csi::EightBitColor.new(
            red: 3,
            green: 8,
            blue: 4,
            layer: :foreground
          ),
          SuperDiff::Csi::TwentyFourBitColor.new(
            red: 47,
            green: 164,
            blue: 59,
            layer: :foreground
          )
        ]

        expected =
          colored("This is a line", colors[0]) + "\n" +
            colored("And that's a line", colors[1]) + "\n" +
            colored("And there's a line too", colors[2]) + "\n"

        actual =
          colored("This is a line", colors[0]) + "\n" +
            colored("Something completely different", colors[1]) + "\n" +
            colored("And there's a line too", colors[2]) + "\n"

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing strings.

          #{
          colored do
            expected_line do
              text "Expected: "
              text %("\\e[34mThis is a line\\e[0m\\n\\e[38;5;176mAnd that's a line\\e[0m\\n\\e[38;2;47;59;164mAnd there's a line too\\e[0m\\n")
            end

            actual_line do
              text "  Actual: "
              text %("\\e[34mThis is a line\\e[0m\\n\\e[38;5;176mSomething completely different\\e[0m\\n\\e[38;2;47;59;164mAnd there's a line too\\e[0m\\n")
            end
          end
        }

          Diff:

          #{
          colored do
            plain_line %(  \\e[34mThis is a line\\e[0m\\n)
            expected_line %(- \\e[38;5;176mAnd that's a line\\e[0m\\n)
            actual_line %(+ \\e[38;5;176mSomething completely different\\e[0m\\n)
            plain_line %(  \\e[38;2;47;59;164mAnd there's a line too\\e[0m\\n)
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given the same array" do
      it "returns an empty string" do
        output =
          described_class.call(
            expected: %w[sausage egg cheese],
            actual: %w[sausage egg cheese]
          )

        expect(output).to eq("")
      end
    end

    context "given two equal-length, one-dimensional arrays with differing numbers" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(expected: [1, 2, 3, 4], actual: [1, 2, 99, 4])

        expected_output = <<~STR.strip
          Differing arrays.

          #{
          colored do
            expected_line "Expected: [1, 2, 3, 4]"
            actual_line "  Actual: [1, 2, 99, 4]"
          end
        }

          Diff:

          #{
          colored do
            plain_line "  ["
            plain_line "    1,"
            plain_line "    2,"
            expected_line "-   3,"
            actual_line "+   99,"
            plain_line "    4"
            plain_line "  ]"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two equal-length, one-dimensional arrays with differing symbols" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: %i[one fish two fish],
            actual: %i[one FISH two fish]
          )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
          colored do
            expected_line "Expected: [:one, :fish, :two, :fish]"
            actual_line "  Actual: [:one, :FISH, :two, :fish]"
          end
        }

          Diff:

          #{
          colored do
            plain_line "  ["
            plain_line "    :one,"
            expected_line "-   :fish,"
            actual_line "+   :FISH,"
            plain_line "    :two,"
            plain_line "    :fish"
            plain_line "  ]"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two equal-length, one-dimensional arrays with differing strings" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: %w[sausage egg cheese],
            actual: %w[bacon egg cheese]
          )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
          colored do
            expected_line %(Expected: ["sausage", "egg", "cheese"])
            actual_line %(  Actual: ["bacon", "egg", "cheese"])
          end
        }

          Diff:

          #{
          colored do
            plain_line "  ["
            expected_line %(-   "sausage",)
            actual_line %(+   "bacon",)
            plain_line %(    "egg",)
            plain_line %(    "cheese")
            plain_line "  ]"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two equal-length, one-dimensional arrays with differing objects" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: [
              SuperDiff::Test::Person.new(name: "Marty", age: 18),
              SuperDiff::Test::Person.new(name: "Jennifer", age: 17)
            ],
            actual: [
              SuperDiff::Test::Person.new(name: "Marty", age: 18),
              SuperDiff::Test::Person.new(name: "Doc", age: 50)
            ]
          )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
          colored do
            expected_line %(Expected: [#<SuperDiff::Test::Person name: "Marty", age: 18>, #<SuperDiff::Test::Person name: "Jennifer", age: 17>])
            actual_line %(  Actual: [#<SuperDiff::Test::Person name: "Marty", age: 18>, #<SuperDiff::Test::Person name: "Doc", age: 50>])
          end
        }

          Diff:

          #{
          colored do
            plain_line "  ["
            plain_line "    #<SuperDiff::Test::Person {"
            plain_line %(      name: "Marty",)
            plain_line "      age: 18"
            plain_line "    }>,"
            plain_line "    #<SuperDiff::Test::Person {"
            expected_line %(-     name: "Jennifer",)
            actual_line %(+     name: "Doc",)
            expected_line "-     age: 17"
            actual_line "+     age: 50"
            plain_line "    }>"
            plain_line "  ]"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has elements added to the end" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(expected: ["bread"], actual: %w[bread eggs milk])

        expected_output = <<~STR.strip
          Differing arrays.

          #{
          colored do
            expected_line %(Expected: ["bread"])
            actual_line %(  Actual: ["bread", "eggs", "milk"])
          end
        }

          Diff:

          #{
          colored do
            plain_line "  ["
            plain_line %(    "bread",)
            actual_line %(+   "eggs",)
            actual_line %(+   "milk")
            plain_line "  ]"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has elements missing from the end" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(expected: %w[bread eggs milk], actual: ["bread"])

        expected_output = <<~STR.strip
          Differing arrays.

          #{
          colored do
            expected_line %(Expected: ["bread", "eggs", "milk"])
            actual_line %(  Actual: ["bread"])
          end
        }

          Diff:

          #{
          colored do
            plain_line "  ["
            plain_line %(    "bread")
            expected_line %(-   "eggs",)
            expected_line %(-   "milk")
            plain_line "  ]"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has elements added to the beginning" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(expected: ["milk"], actual: %w[bread eggs milk])

        expected_output = <<~STR.strip
          Differing arrays.

          #{
          colored do
            expected_line %(Expected: ["milk"])
            actual_line %(  Actual: ["bread", "eggs", "milk"])
          end
        }

          Diff:

          #{
          colored do
            plain_line "  ["
            actual_line %(+   "bread",)
            actual_line %(+   "eggs",)
            plain_line %(    "milk")
            plain_line "  ]"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has elements removed from the beginning" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(expected: %w[bread eggs milk], actual: ["milk"])

        expected_output = <<~STR.strip
          Differing arrays.

          #{
          colored do
            expected_line %(Expected: ["bread", "eggs", "milk"])
            actual_line %(  Actual: ["milk"])
          end
        }

          Diff:

          #{
          colored do
            plain_line "  ["
            expected_line %(-   "bread",)
            expected_line %(-   "eggs",)
            plain_line %(    "milk")
            plain_line "  ]"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two arrays containing arrays with differing values" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: [1, 2, %i[a b c], 4],
            actual: [1, 2, %i[a x c], 4]
          )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
          colored do
            expected_line "Expected: [1, 2, [:a, :b, :c], 4]"
            actual_line "  Actual: [1, 2, [:a, :x, :c], 4]"
          end
        }

          Diff:

          #{
          colored do
            plain_line "  ["
            plain_line "    1,"
            plain_line "    2,"
            plain_line "    ["
            plain_line "      :a,"
            expected_line "-     :b,"
            actual_line "+     :x,"
            plain_line "      :c"
            plain_line "    ],"
            plain_line "    4"
            plain_line "  ]"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two arrays containing hashes with differing values" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: [1, 2, { foo: "bar", baz: "qux" }, 4],
            actual: [1, 2, { foo: "bar", baz: "qox" }, 4]
          )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
          colored do
            expected_line %(Expected: [1, 2, { foo: "bar", baz: "qux" }, 4])
            actual_line %(  Actual: [1, 2, { foo: "bar", baz: "qox" }, 4])
          end
        }

          Diff:

          #{
          colored do
            plain_line "  ["
            plain_line "    1,"
            plain_line "    2,"
            plain_line "    {"
            plain_line %(      foo: "bar",)
            expected_line %(-     baz: "qux")
            actual_line %(+     baz: "qox")
            plain_line "    },"
            plain_line "    4"
            plain_line "  ]"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two arrays containing custom objects with differing attributes" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: [
              1,
              2,
              SuperDiff::Test::Person.new(name: "Marty", age: 18),
              4
            ],
            actual: [1, 2, SuperDiff::Test::Person.new(name: "Doc", age: 50), 4]
          )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
          colored do
            expected_line %(Expected: [1, 2, #<SuperDiff::Test::Person name: "Marty", age: 18>, 4])
            actual_line %(  Actual: [1, 2, #<SuperDiff::Test::Person name: "Doc", age: 50>, 4])
          end
        }

          Diff:

          #{
          colored do
            plain_line "  ["
            plain_line "    1,"
            plain_line "    2,"
            plain_line "    #<SuperDiff::Test::Person {"
            expected_line %(-     name: "Marty",)
            actual_line %(+     name: "Doc",)
            expected_line "-     age: 18"
            actual_line "+     age: 50"
            plain_line "    }>,"
            plain_line "    4"
            plain_line "  ]"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two arrays which contain all different kinds of values, some which differ" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: [
              [
                :h1,
                [:span, [:text, "Hello world"]],
                { class: "header", data: { "sticky" => true } }
              ]
            ],
            actual: [
              [
                :h2,
                [:span, [:text, "Goodbye world"]],
                {
                  id: "hero",
                  class: "header",
                  data: {
                    "sticky" => false,
                    :role => "deprecated"
                  }
                }
              ],
              :br
            ]
          )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
          colored do
            expected_line %(Expected: [[:h1, [:span, [:text, "Hello world"]], { class: "header", data: { "sticky" => true } }]])
            actual_line %(  Actual: [[:h2, [:span, [:text, "Goodbye world"]], { id: "hero", class: "header", data: { "sticky" => false, :role => "deprecated" } }], :br])
          end
        }

          Diff:

          #{
          colored do
            plain_line "  ["
            plain_line "    ["
            expected_line "-     :h1,"
            actual_line "+     :h2,"
            plain_line "      ["
            plain_line "        :span,"
            plain_line "        ["
            plain_line "          :text,"
            expected_line %(-         "Hello world")
            actual_line %(+         "Goodbye world")
            plain_line "        ]"
            plain_line "      ],"
            plain_line "      {"
            actual_line %(+       id: "hero",)
            plain_line %(        class: "header",)
            plain_line "        data: {"
            expected_line %(-         "sticky" => true)
            actual_line %(+         "sticky" => false,)
            actual_line %(+         :role => "deprecated")
            plain_line "        }"
            plain_line "      }"
            plain_line "    ],"
            actual_line "+   :br"
            plain_line "  ]"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given the same hash" do
      it "returns an empty string" do
        output =
          described_class.call(
            expected: {
              name: "Marty"
            },
            actual: {
              name: "Marty"
            }
          )

        expect(output).to eq("")
      end
    end

    context "given two equal-size, one-dimensional hashes where the same key has differing numbers" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: {
              tall: 12,
              grande: 19,
              venti: 20
            },
            actual: {
              tall: 12,
              grande: 16,
              venti: 20
            }
          )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
          colored do
            expected_line "Expected: { tall: 12, grande: 19, venti: 20 }"
            actual_line "  Actual: { tall: 12, grande: 16, venti: 20 }"
          end
        }

          Diff:

          #{
          colored do
            plain_line "  {"
            plain_line "    tall: 12,"
            expected_line "-   grande: 19,"
            actual_line "+   grande: 16,"
            plain_line "    venti: 20"
            plain_line "  }"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where keys are strings and the same key has differing numbers" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: {
              "tall" => 12,
              "grande" => 19,
              "venti" => 20
            },
            actual: {
              "tall" => 12,
              "grande" => 16,
              "venti" => 20
            }
          )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
          colored do
            expected_line %(Expected: { "tall" => 12, "grande" => 19, "venti" => 20 })
            actual_line %(  Actual: { "tall" => 12, "grande" => 16, "venti" => 20 })
          end
        }

          Diff:

          #{
          colored do
            plain_line "  {"
            plain_line %(    "tall" => 12,)
            expected_line %(-   "grande" => 19,)
            actual_line %(+   "grande" => 16,)
            plain_line %(    "venti" => 20)
            plain_line "  }"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the same key has differing symbols" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: {
              tall: :small,
              grande: :grand,
              venti: :large
            },
            actual: {
              tall: :small,
              grande: :medium,
              venti: :large
            }
          )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
          colored do
            expected_line "Expected: { tall: :small, grande: :grand, venti: :large }"
            actual_line "  Actual: { tall: :small, grande: :medium, venti: :large }"
          end
        }

          Diff:

          #{
          colored do
            plain_line "  {"
            plain_line "    tall: :small,"
            expected_line "-   grande: :grand,"
            actual_line "+   grande: :medium,"
            plain_line "    venti: :large"
            plain_line "  }"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the same key has differing strings" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: {
              tall: "small",
              grande: "grand",
              venti: "large"
            },
            actual: {
              tall: "small",
              grande: "medium",
              venti: "large"
            }
          )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
          colored do
            expected_line %(Expected: { tall: "small", grande: "grand", venti: "large" })
            actual_line %(  Actual: { tall: "small", grande: "medium", venti: "large" })
          end
        }

          Diff:

          #{
          colored do
            plain_line "  {"
            plain_line %(    tall: "small",)
            expected_line %(-   grande: "grand",)
            actual_line %(+   grande: "medium",)
            plain_line %(    venti: "large")
            plain_line "  }"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the same key has differing objects" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: {
              steve: SuperDiff::Test::Person.new(name: "Jobs", age: 30),
              susan: SuperDiff::Test::Person.new(name: "Kare", age: 27)
            },
            actual: {
              steve: SuperDiff::Test::Person.new(name: "Wozniak", age: 33),
              susan: SuperDiff::Test::Person.new(name: "Kare", age: 27)
            }
          )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
          colored do
            expected_line %(Expected: { steve: #<SuperDiff::Test::Person name: "Jobs", age: 30>, susan: #<SuperDiff::Test::Person name: "Kare", age: 27> })
            actual_line %(  Actual: { steve: #<SuperDiff::Test::Person name: "Wozniak", age: 33>, susan: #<SuperDiff::Test::Person name: "Kare", age: 27> })
          end
        }

          Diff:

          #{
          colored do
            plain_line "  {"
            plain_line "    steve: #<SuperDiff::Test::Person {"
            expected_line %(-     name: "Jobs",)
            actual_line %(+     name: "Wozniak",)
            expected_line "-     age: 30"
            actual_line "+     age: 33"
            plain_line "    }>,"
            plain_line "    susan: #<SuperDiff::Test::Person {"
            plain_line %(      name: "Kare",)
            plain_line "      age: 27"
            plain_line "    }>"
            plain_line "  }"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the actual has extra keys" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: {
              latte: 4.5
            },
            actual: {
              latte: 4.5,
              mocha: 3.5,
              cortado: 3
            }
          )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
          colored do
            expected_line "Expected: { latte: 4.5 }"
            actual_line "  Actual: { latte: 4.5, mocha: 3.5, cortado: 3 }"
          end
        }

          Diff:

          #{
          colored do
            plain_line "  {"
            plain_line "    latte: 4.5,"
            actual_line "+   mocha: 3.5,"
            actual_line "+   cortado: 3"
            plain_line "  }"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the actual has missing keys" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: {
              latte: 4.5,
              mocha: 3.5,
              cortado: 3
            },
            actual: {
              latte: 4.5
            }
          )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
          colored do
            expected_line "Expected: { latte: 4.5, mocha: 3.5, cortado: 3 }"
            actual_line "  Actual: { latte: 4.5 }"
          end
        }

          Diff:

          #{
          colored do
            plain_line "  {"
            plain_line "    latte: 4.5"
            expected_line "-   mocha: 3.5,"
            expected_line "-   cortado: 3"
            plain_line "  }"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where there is a mixture of missing and extra keys in relatively the same order" do
      context "and the actual value is in relatively the same order as the expected" do
        it "preserves the order of the keys as they are defined" do
          actual_output =
            described_class.call(
              expected: {
                listed_count: 37_009,
                created_at: "Tue Jan 13 19:28:24 +0000 2009",
                favourites_count: 38,
                geo_enabled: false,
                verified: true,
                statuses_count: 273_860,
                media_count: 51_044,
                contributors_enabled: false,
                profile_background_color: "FFF1E0",
                profile_background_image_url_https:
                  "https://abs.twimg.com/images/themes/theme1/bg.png",
                profile_background_tile: false,
                profile_image_url:
                  "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",
                profile_image_url_https:
                  "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",
                profile_banner_url:
                  "https://pbs.twimg.com/profile_banners/18949452/1581526592"
              },
              actual: {
                listed_count: 37_009,
                created_at: "Tue Jan 13 19:28:24 +0000 2009",
                favourites_count: 38,
                utc_offset: nil,
                time_zone: nil,
                statuses_count: 273_860,
                media_count: 51_044,
                contributors_enabled: false,
                is_translator: false,
                is_translation_enabled: false,
                profile_background_color: "FFF1E0",
                profile_background_image_url_https:
                  "https://abs.twimg.com/images/themes/theme1/bg.png",
                profile_background_tile: false,
                profile_banner_url:
                  "https://pbs.twimg.com/profile_banners/18949452/1581526592"
              }
            )

          expected_output = <<~STR.strip
            Differing hashes.

            #{
            colored do
              expected_line %(Expected: { listed_count: 37009, created_at: "Tue Jan 13 19:28:24 +0000 2009", favourites_count: 38, geo_enabled: false, verified: true, statuses_count: 273860, media_count: 51044, contributors_enabled: false, profile_background_color: "FFF1E0", profile_background_image_url_https: "https://abs.twimg.com/images/themes/theme1/bg.png", profile_background_tile: false, profile_image_url: "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg", profile_image_url_https: "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg", profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592" })
              actual_line %(  Actual: { listed_count: 37009, created_at: "Tue Jan 13 19:28:24 +0000 2009", favourites_count: 38, utc_offset: nil, time_zone: nil, statuses_count: 273860, media_count: 51044, contributors_enabled: false, is_translator: false, is_translation_enabled: false, profile_background_color: "FFF1E0", profile_background_image_url_https: "https://abs.twimg.com/images/themes/theme1/bg.png", profile_background_tile: false, profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592" })
            end
          }

            Diff:

            #{
            colored do
              plain_line "  {"
              plain_line "    listed_count: 37009,"
              plain_line %(    created_at: "Tue Jan 13 19:28:24 +0000 2009",)
              plain_line "    favourites_count: 38,"
              expected_line "-   geo_enabled: false,"
              expected_line "-   verified: true,"
              actual_line "+   utc_offset: nil,"
              actual_line "+   time_zone: nil,"
              plain_line "    statuses_count: 273860,"
              plain_line "    media_count: 51044,"
              plain_line "    contributors_enabled: false,"
              actual_line "+   is_translator: false,"
              actual_line "+   is_translation_enabled: false,"
              plain_line %(    profile_background_color: "FFF1E0",)
              plain_line %(    profile_background_image_url_https: "https://abs.twimg.com/images/themes/theme1/bg.png",)
              plain_line "    profile_background_tile: false,"
              expected_line %(-   profile_image_url: "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",)
              expected_line %(-   profile_image_url_https: "https://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",)
              plain_line %(    profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592")
              plain_line "  }"
            end
          }
          STR

          expect(actual_output).to match_output(expected_output)
        end
      end

      context "and the actual value is in a different order than the expected" do
        it "preserves the order of the keys as they are defined" do
          actual_output =
            described_class.call(
              expected: {
                created_at: "Tue Jan 13 19:28:24 +0000 2009",
                favourites_count: 38,
                geo_enabled: false,
                verified: true,
                media_count: 51_044,
                statuses_count: 273_860,
                contributors_enabled: false,
                profile_background_image_url_https:
                  "https://abs.twimg.com/images/themes/theme1/bg.png",
                profile_background_color: "FFF1E0",
                profile_background_tile: false,
                profile_image_url:
                  "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",
                listed_count: 37_009,
                profile_banner_url:
                  "https://pbs.twimg.com/profile_banners/18949452/1581526592"
              },
              actual: {
                listed_count: 37_009,
                created_at: "Tue Jan 13 19:28:24 +0000 2009",
                favourites_count: 38,
                utc_offset: nil,
                statuses_count: 273_860,
                media_count: 51_044,
                contributors_enabled: false,
                is_translator: false,
                is_translation_enabled: false,
                profile_background_color: "FFF1E0",
                profile_background_image_url_https:
                  "https://abs.twimg.com/images/themes/theme1/bg.png",
                profile_banner_url:
                  "https://pbs.twimg.com/profile_banners/18949452/1581526592",
                profile_background_tile: false
              }
            )

          expected_output = <<~STR.strip
            Differing hashes.

            #{
            colored do
              expected_line %(Expected: { created_at: "Tue Jan 13 19:28:24 +0000 2009", favourites_count: 38, geo_enabled: false, verified: true, media_count: 51044, statuses_count: 273860, contributors_enabled: false, profile_background_image_url_https: "https://abs.twimg.com/images/themes/theme1/bg.png", profile_background_color: "FFF1E0", profile_background_tile: false, profile_image_url: "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg", listed_count: 37009, profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592" })
              actual_line %(  Actual: { listed_count: 37009, created_at: "Tue Jan 13 19:28:24 +0000 2009", favourites_count: 38, utc_offset: nil, statuses_count: 273860, media_count: 51044, contributors_enabled: false, is_translator: false, is_translation_enabled: false, profile_background_color: "FFF1E0", profile_background_image_url_https: "https://abs.twimg.com/images/themes/theme1/bg.png", profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592", profile_background_tile: false })
            end
          }

            Diff:

            #{
            colored do
              plain_line "  {"
              plain_line "    listed_count: 37009,"
              plain_line %(    created_at: "Tue Jan 13 19:28:24 +0000 2009",)
              plain_line "    favourites_count: 38,"
              expected_line "-   geo_enabled: false,"
              expected_line "-   verified: true,"
              actual_line "+   utc_offset: nil,"
              plain_line "    statuses_count: 273860,"
              plain_line "    media_count: 51044,"
              plain_line "    contributors_enabled: false,"
              actual_line "+   is_translator: false,"
              actual_line "+   is_translation_enabled: false,"
              plain_line %(    profile_background_color: "FFF1E0",)
              plain_line %(    profile_background_image_url_https: "https://abs.twimg.com/images/themes/theme1/bg.png",)
              expected_line %(-   profile_image_url: "http://pbs.twimg.com/profile_images/931156393108885504/EqEMtLhM_normal.jpg",)
              plain_line %(    profile_banner_url: "https://pbs.twimg.com/profile_banners/18949452/1581526592",)
              plain_line "    profile_background_tile: false"
              plain_line "  }"
            end
          }
          STR

          expect(actual_output).to match_output(expected_output)
        end
      end
    end

    context "given two hashes containing arrays with differing values" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: {
              name: "Elliot",
              interests: %w[music football programming],
              age: 30
            },
            actual: {
              name: "Elliot",
              interests: %w[music travel programming],
              age: 30
            }
          )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
          colored do
            expected_line %(Expected: { name: "Elliot", interests: ["music", "football", "programming"], age: 30 })
            actual_line %(  Actual: { name: "Elliot", interests: ["music", "travel", "programming"], age: 30 })
          end
        }

          Diff:

          #{
          colored do
            plain_line "  {"
            plain_line %(    name: "Elliot",)
            plain_line "    interests: ["
            plain_line %(      "music",)
            expected_line %(-     "football",)
            actual_line %(+     "travel",)
            plain_line %(      "programming")
            plain_line "    ],"
            plain_line "    age: 30"
            plain_line "  }"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two hashes containing hashes with differing values" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: {
              check_spelling: true,
              substitutions: {
                "YOLO" => "You only live once",
                "BRB" => "Buns, ribs, and bacon",
                "YMMV" => "Your mileage may vary"
              },
              check_grammar: false
            },
            actual: {
              check_spelling: true,
              substitutions: {
                "YOLO" => "You only live once",
                "BRB" => "Be right back",
                "YMMV" => "Your mileage may vary"
              },
              check_grammar: false
            }
          )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
          colored do
            expected_line %(Expected: { check_spelling: true, substitutions: { "YOLO" => "You only live once", "BRB" => "Buns, ribs, and bacon", "YMMV" => "Your mileage may vary" }, check_grammar: false })
            actual_line %(  Actual: { check_spelling: true, substitutions: { "YOLO" => "You only live once", "BRB" => "Be right back", "YMMV" => "Your mileage may vary" }, check_grammar: false })
          end
        }

          Diff:

          #{
          colored do
            plain_line "  {"
            plain_line "    check_spelling: true,"
            plain_line "    substitutions: {"
            plain_line %(      "YOLO" => "You only live once",)
            expected_line %(-     "BRB" => "Buns, ribs, and bacon",)
            actual_line %(+     "BRB" => "Be right back",)
            plain_line %(      "YMMV" => "Your mileage may vary")
            plain_line "    },"
            plain_line "    check_grammar: false"
            plain_line "  }"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two hashes containing custom objects with differing attributes" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: {
              order_id: 1234,
              person: SuperDiff::Test::Person.new(name: "Marty", age: 18),
              amount: 350_00
            },
            actual: {
              order_id: 1234,
              person: SuperDiff::Test::Person.new(name: "Doc", age: 50),
              amount: 350_00
            }
          )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
          colored do
            expected_line %(Expected: { order_id: 1234, person: #<SuperDiff::Test::Person name: "Marty", age: 18>, amount: 35000 })
            actual_line %(  Actual: { order_id: 1234, person: #<SuperDiff::Test::Person name: "Doc", age: 50>, amount: 35000 })
          end
        }

          Diff:

          #{
          colored do
            plain_line "  {"
            plain_line "    order_id: 1234,"
            plain_line "    person: #<SuperDiff::Test::Person {"
            expected_line %(-     name: "Marty",)
            actual_line %(+     name: "Doc",)
            expected_line "-     age: 18"
            actual_line "+     age: 50"
            plain_line "    }>,"
            plain_line "    amount: 35000"
            plain_line "  }"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two hashes which contain all different kinds of values, some which differ" do
      it "returns a message along with the diff" do
        actual_output =
          described_class.call(
            expected: {
              customer: {
                name: "Marty McFly",
                shipping_address: {
                  line_1: "123 Main St.",
                  city: "Hill Valley",
                  state: "CA",
                  zip: "90382"
                }
              },
              items: [
                {
                  name: "Fender Stratocaster",
                  cost: 100_000,
                  options: %w[red blue green]
                },
                { name: "Chevy 4x4" }
              ]
            },
            actual: {
              customer: {
                name: "Marty McFly, Jr.",
                shipping_address: {
                  line_1: "456 Ponderosa Ct.",
                  city: "Hill Valley",
                  state: "CA",
                  zip: "90382"
                }
              },
              items: [
                {
                  name: "Fender Stratocaster",
                  cost: 100_000,
                  options: %w[red blue green]
                },
                { name: "Mattel Hoverboard" }
              ]
            }
          )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
          colored do
            expected_line %(Expected: { customer: { name: "Marty McFly", shipping_address: { line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" } }, items: [{ name: "Fender Stratocaster", cost: 100000, options: ["red", "blue", "green"] }, { name: "Chevy 4x4" }] })
            actual_line %(  Actual: { customer: { name: "Marty McFly, Jr.", shipping_address: { line_1: "456 Ponderosa Ct.", city: "Hill Valley", state: "CA", zip: "90382" } }, items: [{ name: "Fender Stratocaster", cost: 100000, options: ["red", "blue", "green"] }, { name: "Mattel Hoverboard" }] })
          end
        }

          Diff:

          #{
          colored do
            plain_line "  {"
            plain_line "    customer: {"
            expected_line %(-     name: "Marty McFly",)
            actual_line %(+     name: "Marty McFly, Jr.",)
            plain_line "      shipping_address: {"
            expected_line %(-       line_1: "123 Main St.",)
            actual_line %(+       line_1: "456 Ponderosa Ct.",)
            plain_line %(        city: "Hill Valley",)
            plain_line %(        state: "CA",)
            plain_line %(        zip: "90382")
            plain_line "      }"
            plain_line "    },"
            plain_line "    items: ["
            plain_line "      {"
            plain_line %(        name: "Fender Stratocaster",)
            plain_line "        cost: 100000,"
            plain_line "        options: ["
            plain_line %(          "red",)
            plain_line %(          "blue",)
            plain_line %(          "green")
            plain_line "        ]"
            plain_line "      },"
            plain_line "      {"
            expected_line %(-       name: "Chevy 4x4")
            actual_line %(+       name: "Mattel Hoverboard")
            plain_line "      }"
            plain_line "    ]"
            plain_line "  }"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two custom objects which == each other" do
      it "returns an empty string" do
        expected = SuperDiff::Test::Person.new(name: "Marty", age: 18)
        actual = SuperDiff::Test::Person.new(name: "Marty", age: 18)

        output = described_class.call(expected: expected, actual: actual)

        expect(output).to eq("")
      end
    end

    context "given two different versions of the same custom class" do
      it "returns a message along with a comparison" do
        expected = SuperDiff::Test::Person.new(name: "Marty", age: 18)
        actual = SuperDiff::Test::Person.new(name: "Doc", age: 50)

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing objects.

          #{
          colored do
            expected_line %(Expected: #<SuperDiff::Test::Person name: "Marty", age: 18>)
            actual_line %(  Actual: #<SuperDiff::Test::Person name: "Doc", age: 50>)
          end
        }

          Diff:

          #{
          colored do
            plain_line "  #<SuperDiff::Test::Person {"
            expected_line %(-   name: "Marty",)
            actual_line %(+   name: "Doc",)
            expected_line "-   age: 18"
            actual_line "+   age: 50"
            plain_line "  }>"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two different versions of the same non-custom class" do
      it "returns a message along with the diff" do
        expected =
          SuperDiff::Test::Player.new(
            handle: "martymcfly",
            character: "mirage",
            inventory: ["flatline", "purple body shield"],
            shields: 0.6,
            health: 0.3,
            ultimate: 0.8
          )
        actual =
          SuperDiff::Test::Player.new(
            handle: "docbrown",
            character: "lifeline",
            inventory: %w[wingman mastiff],
            shields: 0.6,
            health: 0.3,
            ultimate: 0.8
          )

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing objects.

          #{
          colored do
            expected_line %(Expected: #<SuperDiff::Test::Player:#{SuperDiff::Helpers.object_address_for(expected)} @character="mirage", @handle="martymcfly", @health=0.3, @inventory=["flatline", "purple body shield"], @shields=0.6, @ultimate=0.8>)
            actual_line %(  Actual: #<SuperDiff::Test::Player:#{SuperDiff::Helpers.object_address_for(actual)} @character="lifeline", @handle="docbrown", @health=0.3, @inventory=["wingman", "mastiff"], @shields=0.6, @ultimate=0.8>)
          end
        }

          Diff:

          #{
          colored do
            plain_line %(  #<SuperDiff::Test::Player:#{SuperDiff::Helpers.object_address_for(actual)} {)
            expected_line %(-   @character="mirage",)
            actual_line %(+   @character="lifeline",)
            expected_line %(-   @handle="martymcfly",)
            actual_line %(+   @handle="docbrown",)
            plain_line "    @health=0.3,"
            plain_line "    @inventory=["
            expected_line %(-     "flatline",)
            actual_line %(+     "wingman",)
            expected_line %(-     "purple body shield")
            actual_line %(+     "mastiff")
            plain_line "    ],"
            plain_line "    @shields=0.6,"
            plain_line "    @ultimate=0.8"
            plain_line "  }>"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two completely different kinds of custom objects" do
      it "returns a message along with the diff" do
        expected = SuperDiff::Test::Person.new(name: "Marty", age: 31)
        actual =
          SuperDiff::Test::Customer.new(
            name: "Doc",
            shipping_address: :some_shipping_address,
            phone: "1234567890"
          )

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing objects.

          #{
          colored do
            expected_line %(Expected: #<SuperDiff::Test::Person name: "Marty", age: 31>)
            actual_line %(  Actual: #<SuperDiff::Test::Customer name: "Doc", shipping_address: :some_shipping_address, phone: "1234567890">)
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "given two completely different kinds of non-custom objects" do
      it "returns a message along with the diff" do
        expected = SuperDiff::Test::Item.new(name: "camera", quantity: 3)
        actual =
          SuperDiff::Test::Player.new(
            handle: "mcmire",
            character: "Jon",
            inventory: ["sword"],
            shields: 11.4,
            health: 4,
            ultimate: true
          )

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing objects.

          #{
          colored do
            expected_line %(Expected: #<SuperDiff::Test::Item:#{SuperDiff::Helpers.object_address_for(expected)} @name="camera", @quantity=3>)
            actual_line %(  Actual: #<SuperDiff::Test::Player:#{SuperDiff::Helpers.object_address_for(actual)} @character="Jon", @handle="mcmire", @health=4, @inventory=["sword"], @shields=11.4, @ultimate=true>)
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "when the expected value is a data structure that refers to itself somewhere inside of it" do
      it "replaces the reference with ∙∙∙" do
        expected = %w[a b c]
        expected.insert(1, expected)
        actual = %w[a x b c]

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing arrays.

          #{
          colored do
            expected_line %(Expected: ["a", ∙∙∙, "b", "c"])
            actual_line %(  Actual: ["a", "x", "b", "c"])
          end
        }

          Diff:

          #{
          colored do
            plain_line "  ["
            plain_line %(    "a",)
            expected_line "-   ∙∙∙,"
            actual_line %(+   "x",)
            plain_line %(    "b",)
            plain_line %(    "c")
            plain_line "  ]"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "when the actual value is a data structure that refers to itself somewhere inside of it" do
      it "replaces the reference with ∙∙∙" do
        expected = %w[a x b c]
        actual = %w[a b c]
        actual.insert(1, actual)

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing arrays.

          #{
          colored do
            expected_line %(Expected: ["a", "x", "b", "c"])
            actual_line %(  Actual: ["a", ∙∙∙, "b", "c"])
          end
        }

          Diff:

          #{
          colored do
            plain_line "  ["
            plain_line %(    "a",)
            expected_line %(-   "x",)
            actual_line "+   ∙∙∙,"
            plain_line %(    "b",)
            plain_line %(    "c")
            plain_line "  ]"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "when the data structure being different is present inside a secondary layer" do
      it "replaces the reference with ∙∙∙" do
        expected = { foo: %w[a x b c] }
        actual = { foo: %w[a b c] }
        actual[:foo].insert(1, actual)

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing hashes.

          #{
          colored do
            expected_line %(Expected: { foo: ["a", "x", "b", "c"] })
            actual_line %(  Actual: { foo: ["a", ∙∙∙, "b", "c"] })
          end
        }

          Diff:

          #{
          colored do
            plain_line "  {"
            plain_line "    foo: ["
            plain_line %(      "a",)
            expected_line %(-     "x",)
            actual_line "+     ∙∙∙,"
            plain_line %(      "b",)
            plain_line %(      "c")
            plain_line "    ]"
            plain_line "  }"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end

    context "when a secondary layer of a data structure refers to itself" do
      it "replaces the reference with ∙∙∙" do
        expected = { foo: %w[a x b c] }
        actual = { foo: %w[a b c] }
        actual[:foo].insert(1, actual[:foo])

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing hashes.

          #{
          colored do
            expected_line %(Expected: { foo: ["a", "x", "b", "c"] })
            actual_line %(  Actual: { foo: ["a", ∙∙∙, "b", "c"] })
          end
        }

          Diff:

          #{
          colored do
            plain_line "  {"
            plain_line "    foo: ["
            plain_line %(      "a",)
            expected_line %(-     "x",)
            actual_line "+     ∙∙∙,"
            plain_line %(      "b",)
            plain_line %(      "c")
            plain_line "    ]"
            plain_line "  }"
          end
        }
        STR

        expect(actual_output).to match_output(expected_output)
      end
    end
  end
end
