require "spec_helper"

RSpec.describe SuperDiff::EqualityMatcher do
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
              alpha_line %(Expected: 42)
              beta_line  %(  Actual: 1)
            end
          }
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

        expected_output = <<~STR.strip
          Differing symbols.

          #{
            colored do
              alpha_line %(Expected: :foo)
              beta_line  %(  Actual: :bar)
            end
          }
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
          actual: "Jennifer",
        )

        expected_output = <<~STR.strip
          Differing strings.

          #{
            colored do
              alpha_line %(Expected: "Marty")
              beta_line  %(  Actual: "Jennifer")
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given closely different single-line strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: "Marty",
          actual: "Marty McFly",
        )

        expected_output = <<~STR.strip
          Differing strings.

          #{
            colored do
              alpha_line %(Expected: "Marty")
              beta_line  %(  Actual: "Marty McFly")
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given a single-line string and a multi-line string" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: "Something entirely different",
          actual: "This is a line\nAnd that's another line\n",
        )

        expected_output = <<~STR.strip
          Differing strings.

          #{
            colored do
              alpha_line %(Expected: "Something entirely different")
              beta_line  %(  Actual: "This is a line\\nAnd that's another line\\n")
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given a multi-line string and a single-line string" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: "This is a line\nAnd that's another line\n",
          actual: "Something entirely different",
        )

        expected_output = <<~STR.strip
          Differing strings.

          #{
            colored do
              alpha_line %(Expected: "This is a line\\nAnd that's another line\\n")
              beta_line  %(  Actual: "Something entirely different")
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given closely different multi-line strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: "This is a line\nAnd that's a line\nAnd there's a line too",
          actual: "This is a line\nSomething completely different\nAnd there's a line too",
        )

        expected_output = <<~STR.strip
          Differing strings.

          #{
            colored do
              alpha_line %(Expected: "This is a line\\nAnd that's a line\\nAnd there's a line too")
              beta_line  %(  Actual: "This is a line\\nSomething completely different\\nAnd there's a line too")
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  This is a line\\n)
              alpha_line %(- And that's a line\\n)
              beta_line  %(+ Something completely different\\n)
              plain_line %(  And there's a line too)
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given completely different multi-line strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: "This is a line\nAnd that's a line\n",
          actual: "Something completely different\nAnd something else too\n",
        )

        expected_output = <<~STR.strip
          Differing strings.

          #{
            colored do
              alpha_line %(Expected: "This is a line\\nAnd that's a line\\n")
              beta_line  %(  Actual: "Something completely different\\nAnd something else too\\n")
            end
          }

          Diff:

          #{
            colored do
              alpha_line %(- This is a line\\n)
              alpha_line %(- And that's a line\\n)
              beta_line  %(+ Something completely different\\n)
              beta_line  %(+ And something else too\\n)
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
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
            layer: :foreground,
          ),
          SuperDiff::Csi::TwentyFourBitColor.new(
            red: 47,
            green: 164,
            blue: 59,
            layer: :foreground,
          ),
        ]

        expected =
          colored("This is a line", colors[0]) + "\n" +
          colored("And that's a line", colors[1]) + "\n" +
          colored("And there's a line too", colors[2]) + "\n"

        actual =
          colored("This is a line", colors[0])  + "\n" +
          colored("Something completely different", colors[1]) + "\n" +
          colored("And there's a line too", colors[2]) + "\n"

        actual_output = described_class.call(
          expected: expected,
          actual: actual,
        )

        expected_output = <<~STR.strip
          Differing strings.

          #{
            colored do
              alpha_line do
                text "Expected: "
                text %("\\e[34mThis is a line\\e[0m\\n\\e[38;5;176mAnd that's a line\\e[0m\\n\\e[38;2;47;59;164mAnd there's a line too\\e[0m\\n")
              end

              beta_line do
                text "  Actual: "
                text %("\\e[34mThis is a line\\e[0m\\n\\e[38;5;176mSomething completely different\\e[0m\\n\\e[38;2;47;59;164mAnd there's a line too\\e[0m\\n")
              end
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  \\e[34mThis is a line\\e[0m\\n)
              alpha_line %(- \\e[38;5;176mAnd that's a line\\e[0m\\n)
              beta_line  %(+ \\e[38;5;176mSomething completely different\\e[0m\\n)
              plain_line %(  \\e[38;2;47;59;164mAnd there's a line too\\e[0m\\n)
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given the same array" do
      it "returns an empty string" do
        output = described_class.call(
          expected: ["sausage", "egg", "cheese"],
          actual: ["sausage", "egg", "cheese"],
        )

        expect(output).to eq("")
      end
    end

    context "given two equal-length, one-dimensional arrays with differing numbers" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [1, 2, 3, 4],
          actual: [1, 2, 99, 4],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              alpha_line %(Expected: [1, 2, 3, 4])
              beta_line  %(  Actual: [1, 2, 99, 4])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    1,)
              plain_line %(    2,)
              alpha_line %(-   3,)
              beta_line  %(+   99,)
              plain_line %(    4)
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-length, one-dimensional arrays with differing symbols" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [:one, :fish, :two, :fish],
          actual: [:one, :FISH, :two, :fish],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              alpha_line %(Expected: [:one, :fish, :two, :fish])
              beta_line  %(  Actual: [:one, :FISH, :two, :fish])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    :one,)
              alpha_line %(-   :fish,)
              beta_line  %(+   :FISH,)
              plain_line %(    :two,)
              plain_line %(    :fish)
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-length, one-dimensional arrays with differing strings" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["sausage", "egg", "cheese"],
          actual: ["bacon", "egg", "cheese"],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              alpha_line %(Expected: ["sausage", "egg", "cheese"])
              beta_line  %(  Actual: ["bacon", "egg", "cheese"])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              alpha_line %(-   "sausage",)
              beta_line  %(+   "bacon",)
              plain_line %(    "egg",)
              plain_line %(    "cheese")
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-length, one-dimensional arrays with differing objects" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [
            SuperDiff::Test::Person.new(name: "Marty", age: 18),
            SuperDiff::Test::Person.new(name: "Jennifer", age: 17),
          ],
          actual: [
            SuperDiff::Test::Person.new(name: "Marty", age: 18),
            SuperDiff::Test::Person.new(name: "Doc", age: 50),
          ],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              alpha_line %(Expected: [#<SuperDiff::Test::Person name: "Marty", age: 18>, #<SuperDiff::Test::Person name: "Jennifer", age: 17>])
              beta_line  %(  Actual: [#<SuperDiff::Test::Person name: "Marty", age: 18>, #<SuperDiff::Test::Person name: "Doc", age: 50>])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    #<SuperDiff::Test::Person {)
              plain_line %(      name: "Marty",)
              plain_line %(      age: 18)
              plain_line %(    }>,)
              plain_line %(    #<SuperDiff::Test::Person {)
              alpha_line %(-     name: "Jennifer",)
              beta_line  %(+     name: "Doc",)
              alpha_line %(-     age: 17)
              beta_line  %(+     age: 50)
              plain_line %(    }>)
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has elements added to the end" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["bread"],
          actual: ["bread", "eggs", "milk"],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              alpha_line %(Expected: ["bread"])
              beta_line  %(  Actual: ["bread", "eggs", "milk"])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    "bread",)
              beta_line  %(+   "eggs",)
              beta_line  %(+   "milk")
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has elements missing from the end" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["bread", "eggs", "milk"],
          actual: ["bread"],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              alpha_line %(Expected: ["bread", "eggs", "milk"])
              beta_line  %(  Actual: ["bread"])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    "bread")
              alpha_line %(-   "eggs",)
              alpha_line %(-   "milk")
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has elements added to the beginning" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["milk"],
          actual: ["bread", "eggs", "milk"],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              alpha_line %(Expected: ["milk"])
              beta_line  %(  Actual: ["bread", "eggs", "milk"])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              beta_line  %(+   "bread",)
              beta_line  %(+   "eggs",)
              plain_line %(    "milk")
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two one-dimensional arrays where the actual has elements removed from the beginning" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: ["bread", "eggs", "milk"],
          actual: ["milk"],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              alpha_line %(Expected: ["bread", "eggs", "milk"])
              beta_line  %(  Actual: ["milk"])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              alpha_line %(-   "bread",)
              alpha_line %(-   "eggs",)
              plain_line %(    "milk")
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two arrays containing arrays with differing values" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [1, 2, [:a, :b, :c], 4],
          actual: [1, 2, [:a, :x, :c], 4],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              alpha_line %(Expected: [1, 2, [:a, :b, :c], 4])
              beta_line  %(  Actual: [1, 2, [:a, :x, :c], 4])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    1,)
              plain_line %(    2,)
              plain_line %(    [)
              plain_line %(      :a,)
              alpha_line %(-     :b,)
              beta_line  %(+     :x,)
              plain_line %(      :c)
              plain_line %(    ],)
              plain_line %(    4)
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two arrays containing hashes with differing values" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [1, 2, { foo: "bar", baz: "qux" }, 4],
          actual: [1, 2, { foo: "bar", baz: "qox" }, 4],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              alpha_line %(Expected: [1, 2, { foo: "bar", baz: "qux" }, 4])
              beta_line  %(  Actual: [1, 2, { foo: "bar", baz: "qox" }, 4])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    1,)
              plain_line %(    2,)
              plain_line %(    {)
              plain_line %(      foo: "bar",)
              alpha_line %(-     baz: "qux")
              beta_line  %(+     baz: "qox")
              plain_line %(    },)
              plain_line %(    4)
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two arrays containing custom objects with differing attributes" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [
            1,
            2,
            SuperDiff::Test::Person.new(name: "Marty", age: 18),
            4,
          ],
          actual: [1, 2, SuperDiff::Test::Person.new(name: "Doc", age: 50), 4],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              alpha_line %(Expected: [1, 2, #<SuperDiff::Test::Person name: "Marty", age: 18>, 4])
              beta_line  %(  Actual: [1, 2, #<SuperDiff::Test::Person name: "Doc", age: 50>, 4])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    1,)
              plain_line %(    2,)
              plain_line %(    #<SuperDiff::Test::Person {)
              alpha_line %(-     name: "Marty",)
              beta_line  %(+     name: "Doc",)
              alpha_line %(-     age: 18)
              beta_line  %(+     age: 50)
              plain_line %(    }>,)
              plain_line %(    4)
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two arrays which contain all different kinds of values, some which differ" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: [
            [
              :h1,
              [:span, [:text, "Hello world"]],
              {
                class: "header",
                data: { "sticky" => true },
              },
            ],
          ],
          actual: [
            [
              :h2,
              [:span, [:text, "Goodbye world"]],
              {
                id: "hero",
                class: "header",
                data: { "sticky" => false, role: "deprecated" },
              },
            ],
            :br,
          ],
        )

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              alpha_line %(Expected: [[:h1, [:span, [:text, "Hello world"]], { class: "header", data: { "sticky" => true } }]])
              beta_line  %(  Actual: [[:h2, [:span, [:text, "Goodbye world"]], { id: "hero", class: "header", data: { "sticky" => false, :role => "deprecated" } }], :br])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    [)
              alpha_line %(-     :h1,)
              beta_line  %(+     :h2,)
              plain_line %(      [)
              plain_line %(        :span,)
              plain_line %(        [)
              plain_line %(          :text,)
              alpha_line %(-         "Hello world")
              beta_line  %(+         "Goodbye world")
              plain_line %(        ])
              plain_line %(      ],)
              plain_line %(      {)
              beta_line  %(+       id: "hero",)
              plain_line %(        class: "header",)
              plain_line %(        data: {)
              alpha_line %(-         "sticky" => true)
              beta_line  %(+         "sticky" => false,)
              beta_line  %(+         role: "deprecated")
              plain_line %(        })
              plain_line %(      })
              plain_line %(    ],)
              beta_line  %(+   :br)
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given the same hash" do
      it "returns an empty string" do
        output = described_class.call(
          expected: { name: "Marty" },
          actual: { name: "Marty" },
        )

        expect(output).to eq("")
      end
    end

    context "given two equal-size, one-dimensional hashes where the same key has differing numbers" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: { tall: 12, grande: 19, venti: 20 },
          actual: { tall: 12, grande: 16, venti: 20 },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              alpha_line %(Expected: { tall: 12, grande: 19, venti: 20 })
              beta_line  %(  Actual: { tall: 12, grande: 16, venti: 20 })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    tall: 12,)
              alpha_line %(-   grande: 19,)
              beta_line  %(+   grande: 16,)
              plain_line %(    venti: 20)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where keys are strings and the same key has differing numbers" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: { "tall" => 12, "grande" => 19, "venti" => 20 },
          actual: { "tall" => 12, "grande" => 16, "venti" => 20 },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              alpha_line %(Expected: { "tall" => 12, "grande" => 19, "venti" => 20 })
              beta_line  %(  Actual: { "tall" => 12, "grande" => 16, "venti" => 20 })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    "tall" => 12,)
              alpha_line %(-   "grande" => 19,)
              beta_line  %(+   "grande" => 16,)
              plain_line %(    "venti" => 20)
              plain_line %(  })
            end
          }
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

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              alpha_line %(Expected: { tall: :small, grande: :grand, venti: :large })
              beta_line  %(  Actual: { tall: :small, grande: :medium, venti: :large })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    tall: :small,)
              alpha_line %(-   grande: :grand,)
              beta_line  %(+   grande: :medium,)
              plain_line %(    venti: :large)
              plain_line %(  })
            end
          }
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

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              alpha_line %(Expected: { tall: "small", grande: "grand", venti: "large" })
              beta_line  %(  Actual: { tall: "small", grande: "medium", venti: "large" })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    tall: "small",)
              alpha_line %(-   grande: "grand",)
              beta_line  %(+   grande: "medium",)
              plain_line %(    venti: "large")
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the same key has differing objects" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: {
            steve: SuperDiff::Test::Person.new(name: "Jobs", age: 30),
            susan: SuperDiff::Test::Person.new(name: "Kare", age: 27),
          },
          actual: {
            steve: SuperDiff::Test::Person.new(name: "Wozniak", age: 33),
            susan: SuperDiff::Test::Person.new(name: "Kare", age: 27),
          },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              alpha_line %(Expected: { steve: #<SuperDiff::Test::Person name: "Jobs", age: 30>, susan: #<SuperDiff::Test::Person name: "Kare", age: 27> })
              beta_line  %(  Actual: { steve: #<SuperDiff::Test::Person name: "Wozniak", age: 33>, susan: #<SuperDiff::Test::Person name: "Kare", age: 27> })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    steve: #<SuperDiff::Test::Person {)
              alpha_line %(-     name: "Jobs",)
              beta_line  %(+     name: "Wozniak",)
              alpha_line %(-     age: 30)
              beta_line  %(+     age: 33)
              plain_line %(    }>,)
              plain_line %(    susan: #<SuperDiff::Test::Person {)
              plain_line %(      name: "Kare",)
              plain_line %(      age: 27)
              plain_line %(    }>)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the actual has extra keys" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: { latte: 4.5 },
          actual: { latte: 4.5, mocha: 3.5, cortado: 3 },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              alpha_line %(Expected: { latte: 4.5 })
              beta_line  %(  Actual: { latte: 4.5, mocha: 3.5, cortado: 3 })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    latte: 4.5,)
              beta_line  %(+   mocha: 3.5,)
              beta_line  %(+   cortado: 3)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two equal-size, one-dimensional hashes where the actual has missing keys" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: { latte: 4.5, mocha: 3.5, cortado: 3 },
          actual: { latte: 4.5 },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              alpha_line %(Expected: { latte: 4.5, mocha: 3.5, cortado: 3 })
              beta_line  %(  Actual: { latte: 4.5 })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    latte: 4.5)
              alpha_line %(-   mocha: 3.5,)
              alpha_line %(-   cortado: 3)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two hashes containing arrays with differing values" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: {
            name: "Elliot",
            interests: ["music", "football", "programming"],
            age: 30,
          },
          actual: {
            name: "Elliot",
            interests: ["music", "travel", "programming"],
            age: 30,
          },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              alpha_line %(Expected: { name: "Elliot", interests: ["music", "football", "programming"], age: 30 })
              beta_line  %(  Actual: { name: "Elliot", interests: ["music", "travel", "programming"], age: 30 })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    name: "Elliot",)
              plain_line %(    interests: [)
              plain_line %(      "music",)
              alpha_line %(-     "football",)
              beta_line  %(+     "travel",)
              plain_line %(      "programming")
              plain_line %(    ],)
              plain_line %(    age: 30)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two hashes containing hashes with differing values" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: {
            check_spelling: true,
            substitutions: {
              "YOLO" => "You only live once",
              "BRB" => "Buns, ribs, and bacon",
              "YMMV" => "Your mileage may vary",
            },
            check_grammar: false,
          },
          actual: {
            check_spelling: true,
            substitutions: {
              "YOLO" => "You only live once",
              "BRB" => "Be right back",
              "YMMV" => "Your mileage may vary",
            },
            check_grammar: false,
          },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              alpha_line %(Expected: { check_spelling: true, substitutions: { "YOLO" => "You only live once", "BRB" => "Buns, ribs, and bacon", "YMMV" => "Your mileage may vary" }, check_grammar: false })
              beta_line  %(  Actual: { check_spelling: true, substitutions: { "YOLO" => "You only live once", "BRB" => "Be right back", "YMMV" => "Your mileage may vary" }, check_grammar: false })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    check_spelling: true,)
              plain_line %(    substitutions: {)
              plain_line %(      "YOLO" => "You only live once",)
              alpha_line %(-     "BRB" => "Buns, ribs, and bacon",)
              beta_line  %(+     "BRB" => "Be right back",)
              plain_line %(      "YMMV" => "Your mileage may vary")
              plain_line %(    },)
              plain_line %(    check_grammar: false)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two hashes containing custom objects with differing attributes" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: {
            order_id: 1234,
            person: SuperDiff::Test::Person.new(name: "Marty", age: 18),
            amount: 350_00,
          },
          actual: {
            order_id: 1234,
            person: SuperDiff::Test::Person.new(name: "Doc", age: 50),
            amount: 350_00,
          },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              alpha_line %(Expected: { order_id: 1234, person: #<SuperDiff::Test::Person name: "Marty", age: 18>, amount: 35000 })
              beta_line  %(  Actual: { order_id: 1234, person: #<SuperDiff::Test::Person name: "Doc", age: 50>, amount: 35000 })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    order_id: 1234,)
              plain_line %(    person: #<SuperDiff::Test::Person {)
              alpha_line %(-     name: "Marty",)
              beta_line  %(+     name: "Doc",)
              alpha_line %(-     age: 18)
              beta_line  %(+     age: 50)
              plain_line %(    }>,)
              plain_line %(    amount: 35000)
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two hashes which contain all different kinds of values, some which differ" do
      it "returns a message along with the diff" do
        actual_output = described_class.call(
          expected: {
            customer: {
              name: "Marty McFly",
              shipping_address: {
                line_1: "123 Main St.",
                city: "Hill Valley",
                state: "CA",
                zip: "90382",
              },
            },
            items: [
              {
                name: "Fender Stratocaster",
                cost: 100_000,
                options: ["red", "blue", "green"],
              },
              { name: "Chevy 4x4" },
            ],
          },
          actual: {
            customer: {
              name: "Marty McFly, Jr.",
              shipping_address: {
                line_1: "456 Ponderosa Ct.",
                city: "Hill Valley",
                state: "CA",
                zip: "90382",
              },
            },
            items: [
              {
                name: "Fender Stratocaster",
                cost: 100_000,
                options: ["red", "blue", "green"],
              },
              { name: "Mattel Hoverboard" },
            ],
          },
        )

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              alpha_line %(Expected: { customer: { name: "Marty McFly", shipping_address: { line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" } }, items: [{ name: "Fender Stratocaster", cost: 100000, options: ["red", "blue", "green"] }, { name: "Chevy 4x4" }] })
              beta_line  %(  Actual: { customer: { name: "Marty McFly, Jr.", shipping_address: { line_1: "456 Ponderosa Ct.", city: "Hill Valley", state: "CA", zip: "90382" } }, items: [{ name: "Fender Stratocaster", cost: 100000, options: ["red", "blue", "green"] }, { name: "Mattel Hoverboard" }] })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    customer: {)
              alpha_line %(-     name: "Marty McFly",)
              beta_line  %(+     name: "Marty McFly, Jr.",)
              plain_line %(      shipping_address: {)
              alpha_line %(-       line_1: "123 Main St.",)
              beta_line  %(+       line_1: "456 Ponderosa Ct.",)
              plain_line %(        city: "Hill Valley",)
              plain_line %(        state: "CA",)
              plain_line %(        zip: "90382")
              plain_line %(      })
              plain_line %(    },)
              plain_line %(    items: [)
              plain_line %(      {)
              plain_line %(        name: "Fender Stratocaster",)
              plain_line %(        cost: 100000,)
              plain_line %(        options: [)
              plain_line %(          "red",)
              plain_line %(          "blue",)
              plain_line %(          "green")
              plain_line %(        ])
              plain_line %(      },)
              plain_line %(      {)
              alpha_line %(-       name: "Chevy 4x4")
              beta_line  %(+       name: "Mattel Hoverboard")
              plain_line %(      })
              plain_line %(    ])
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
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

        actual_output = described_class.call(
          expected: expected,
          actual: actual,
        )

        expected_output = <<~STR.strip
          Differing objects.

          #{
            colored do
              alpha_line %(Expected: #<SuperDiff::Test::Person name: "Marty", age: 18>)
              beta_line  %(  Actual: #<SuperDiff::Test::Person name: "Doc", age: 50>)
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  #<SuperDiff::Test::Person {)
              alpha_line %(-   name: "Marty",)
              beta_line  %(+   name: "Doc",)
              alpha_line %(-   age: 18)
              beta_line  %(+   age: 50)
              plain_line %(  }>)
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two different versions of the same non-custom class" do
      it "returns a message along with the diff" do
        expected = SuperDiff::Test::Player.new(
          handle: "martymcfly",
          character: "mirage",
          inventory: ["flatline", "purple body shield"],
          shields: 0.6,
          health: 0.3,
          ultimate: 0.8,
        )
        actual = SuperDiff::Test::Player.new(
          handle: "docbrown",
          character: "lifeline",
          inventory: ["wingman", "mastiff"],
          shields: 0.6,
          health: 0.3,
          ultimate: 0.8,
        )

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing objects.

          #{
            if SuperDiff::Test.jruby?
              # Source: <https://github.com/jruby/jruby/blob/master/core/src/main/java/org/jruby/RubyBasicObject.java>
              colored do
                alpha_line %(Expected: #<SuperDiff::Test::Player:#{SuperDiff::Test.object_id_hex(expected)} @inventory=["flatline", "purple body shield"], @character="mirage", @handle="martymcfly", @ultimate=0.8, @shields=0.6, @health=0.3>)
                beta_line  %(  Actual: #<SuperDiff::Test::Player:#{SuperDiff::Test.object_id_hex(actual)} @inventory=["wingman", "mastiff"], @character="lifeline", @handle="docbrown", @ultimate=0.8, @shields=0.6, @health=0.3>)
              end
            else
              colored do
                alpha_line %(Expected: #<SuperDiff::Test::Player:#{SuperDiff::Test.object_id_hex(expected)} @handle="martymcfly", @character="mirage", @inventory=["flatline", "purple body shield"], @shields=0.6, @health=0.3, @ultimate=0.8>)
                beta_line  %(  Actual: #<SuperDiff::Test::Player:#{SuperDiff::Test.object_id_hex(actual)} @handle="docbrown", @character="lifeline", @inventory=["wingman", "mastiff"], @shields=0.6, @health=0.3, @ultimate=0.8>)
              end
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  #<SuperDiff::Test::Player {)
              alpha_line %(-   @character="mirage",)
              beta_line  %(+   @character="lifeline",)
              alpha_line %(-   @handle="martymcfly",)
              beta_line  %(+   @handle="docbrown",)
              plain_line %(    @health=0.3,)
              plain_line %(    @inventory=[)
              alpha_line %(-     "flatline",)
              beta_line  %(+     "wingman",)
              alpha_line %(-     "purple body shield")
              beta_line  %(+     "mastiff")
              plain_line %(    ],)
              plain_line %(    @shields=0.6,)
              plain_line %(    @ultimate=0.8)
              plain_line %(  }>)
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two completely different kinds of custom objects" do
      it "returns a message along with the diff" do
        expected = SuperDiff::Test::Person.new(
          name: "Marty",
          age: 31,
        )
        actual = SuperDiff::Test::Customer.new(
          name: "Doc",
          shipping_address: :some_shipping_address,
          phone: "1234567890",
        )

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing objects.

          #{
            colored do
              alpha_line %(Expected: #<SuperDiff::Test::Person name: "Marty", age: 31>)
              beta_line  %(  Actual: #<SuperDiff::Test::Customer name: "Doc", shipping_address: :some_shipping_address, phone: "1234567890">)
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "given two completely different kinds of non-custom objects" do
      it "returns a message along with the diff" do
        expected = SuperDiff::Test::Item.new(
          name: "camera",
          quantity: 3,
        )
        actual = SuperDiff::Test::Player.new(
          handle: "mcmire",
          character: "Jon",
          inventory: ["sword"],
          shields: 11.4,
          health: 4,
          ultimate: true,
        )

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing objects.

          #{
            if SuperDiff::Test.jruby?
              # Source: <https://github.com/jruby/jruby/blob/master/core/src/main/java/org/jruby/RubyBasicObject.java>
              colored do
                alpha_line %(Expected: #<SuperDiff::Test::Item:#{SuperDiff::Test.object_id_hex(expected)} @name="camera", @quantity=3>)
                beta_line  %(  Actual: #<SuperDiff::Test::Player:#{SuperDiff::Test.object_id_hex(actual)} @inventory=["sword"], @character="Jon", @handle="mcmire", @ultimate=true, @shields=11.4, @health=4>)
              end
            else
              colored do
                alpha_line %(Expected: #<SuperDiff::Test::Item:#{SuperDiff::Test.object_id_hex(expected)} @name="camera", @quantity=3>)
                beta_line  %(  Actual: #<SuperDiff::Test::Player:#{SuperDiff::Test.object_id_hex(actual)} @handle="mcmire", @character="Jon", @inventory=["sword"], @shields=11.4, @health=4, @ultimate=true>)
              end
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "when the expected value is a data structure that refers to itself somewhere inside of it" do
      it "replaces the reference with ∙∙∙" do
        expected = ["a", "b", "c"]
        expected.insert(1, expected)
        actual = ["a", "x", "b", "c"]

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              alpha_line %(Expected: ["a", ∙∙∙, "b", "c"])
              beta_line  %(  Actual: ["a", "x", "b", "c"])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    "a",)
              alpha_line %(-   ∙∙∙,)
              beta_line  %(+   "x",)
              plain_line %(    "b",)
              plain_line %(    "c")
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "when the actual value is a data structure that refers to itself somewhere inside of it" do
      it "replaces the reference with ∙∙∙" do
        expected = ["a", "x", "b", "c"]
        actual = ["a", "b", "c"]
        actual.insert(1, actual)

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing arrays.

          #{
            colored do
              alpha_line %(Expected: ["a", "x", "b", "c"])
              beta_line  %(  Actual: ["a", ∙∙∙, "b", "c"])
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  [)
              plain_line %(    "a",)
              alpha_line %(-   "x",)
              beta_line  %(+   ∙∙∙,)
              plain_line %(    "b",)
              plain_line %(    "c")
              plain_line %(  ])
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "when the data structure being different is present inside a secondary layer" do
      it "replaces the reference with ∙∙∙" do
        expected = { foo: ["a", "x", "b", "c"] }
        actual = { foo: ["a", "b", "c"] }
        actual[:foo].insert(1, actual)

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              alpha_line %(Expected: { foo: ["a", "x", "b", "c"] })
              beta_line  %(  Actual: { foo: ["a", ∙∙∙, "b", "c"] })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    foo: [)
              plain_line %(      "a",)
              alpha_line %(-     "x",)
              beta_line  %(+     ∙∙∙,)
              plain_line %(      "b",)
              plain_line %(      "c")
              plain_line %(    ])
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end

    context "when a secondary layer of a data structure refers to itself" do
      it "replaces the reference with ∙∙∙" do
        expected = { foo: ["a", "x", "b", "c"] }
        actual = { foo: ["a", "b", "c"] }
        actual[:foo].insert(1, actual[:foo])

        actual_output = described_class.call(expected: expected, actual: actual)

        expected_output = <<~STR.strip
          Differing hashes.

          #{
            colored do
              alpha_line %(Expected: { foo: ["a", "x", "b", "c"] })
              beta_line  %(  Actual: { foo: ["a", ∙∙∙, "b", "c"] })
            end
          }

          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    foo: [)
              plain_line %(      "a",)
              alpha_line %(-     "x",)
              beta_line  %(+     ∙∙∙,)
              plain_line %(      "b",)
              plain_line %(      "c")
              plain_line %(    ])
              plain_line %(  })
            end
          }
        STR

        expect(actual_output).to eq(expected_output)
      end
    end
  end

  def colored(*args, **opts, &block)
    SuperDiff::Helpers.style(*args, **opts, &block).to_s.chomp
  end
end
