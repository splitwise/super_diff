require "spec_helper"

RSpec.describe "Integration with RSpec", type: :integration do
  context "comparing two different integers" do
    it "produces the correct output" do
      test = <<~TEST
        expect(1).to eq(42)
      TEST

      expected_output = <<~OUTPUT
        expected: 42
             got: 1
      OUTPUT

      expect(test).to produce_output_when_run(expected_output)
    end
  end

  context "comparing two different symbols" do
    it "produces the correct output" do
      test = <<~TEST
        expect(:bar).to eq(:foo)
      TEST

      expected_output = <<~OUTPUT
        expected: :foo
             got: :bar
      OUTPUT

      expect(test).to produce_output_when_run(expected_output)
    end
  end

  context "comparing two different single-line strings" do
    it "produces the correct output" do
      test = <<~TEST
        expect("Jennifer").to eq("Marty")
      TEST

      expected_output = <<~OUTPUT
        expected: "Marty"
             got: "Jennifer"
      OUTPUT

      expect(test).to produce_output_when_run(expected_output)
    end
  end

  context "comparing two closely different multi-line strings" do
    it "produces the correct output" do
      test = <<~TEST
        expected = "This is a line\\nAnd that's a line\\nAnd there's a line too"
        actual = "This is a line\\nSomething completely different\\nAnd there's a line too"
        expect(actual).to eq(expected)
      TEST

      expected_output = <<~OUTPUT
        Diff:

        #{
          colored do
            plain_line %(  This is a line⏎)
            red_line   %(- And that's a line⏎)
            green_line %(+ Something completely different⏎)
            plain_line %(  And there's a line too)
          end
        }
      OUTPUT

      expect(test).to produce_output_when_run(expected_output)
    end
  end

  context "comparing two completely different multi-line strings" do
    it "produces the correct output" do
      test = <<~TEST
        expected = "This is a line\\nAnd that's a line\\n"
        actual = "Something completely different\\nAnd something else too\\n"
        expect(actual).to eq(expected)
      TEST

      expected_output = <<~OUTPUT
        Diff:

        #{
          colored do
            red_line   %(- This is a line⏎)
            red_line   %(- And that's a line⏎)
            green_line %(+ Something completely different⏎)
            green_line %(+ And something else too⏎)
          end
        }
      OUTPUT

      expect(test).to produce_output_when_run(expected_output)
    end
  end

  context "comparing two arrays with other data structures inside" do
    it "produces the correct output" do
      test = <<~TEST
        expected = [
          [
            :h1,
            [:span, [:text, "Hello world"]],
            {
              class: "header",
              data: {
                "sticky" => true,
                person: SuperDiff::Test::Person.new(name: "Marty", age: 60)
              }
            }
          ]
        ]
        actual = [
          [
            :h2,
            [:span, [:text, "Goodbye world"]],
            {
              id: "hero",
              class: "header",
              data: {
                "sticky" => false,
                role: "deprecated",
                person: SuperDiff::Test::Person.new(name: "Doc", age: 60)
              }
            }
          ],
          :br
        ]
        expect(actual).to eq(expected)
      TEST

      expected_output = <<~OUTPUT
        Diff:

        #{
          colored do
            plain_line %(  [)
            plain_line %(    [)
            red_line   %(-     :h1,)
            green_line %(+     :h2,)
            plain_line %(      [)
            plain_line %(        :span,)
            plain_line %(        [)
            plain_line %(          :text,)
            red_line   %(-         "Hello world")
            green_line %(+         "Goodbye world")
            plain_line %(        ])
            plain_line %(      ],)
            plain_line %(      {)
            green_line %(+       id: "hero",)
            plain_line %(        class: "header",)
            plain_line %(        data: {)
            red_line   %(-         "sticky" => true,)
            green_line %(+         "sticky" => false,)
            green_line %(+         role: "deprecated",)
            plain_line %(          person: #<SuperDiff::Test::Person {)
            red_line   %(-           name: "Marty",)
            green_line %(+           name: "Doc",)
            plain_line %(            age: 60)
            plain_line %(          }>)
            plain_line %(        })
            plain_line %(      })
            plain_line %(    ],)
            green_line %(+   :br)
            plain_line %(  ])
          end
        }
      OUTPUT

      expect(test).to produce_output_when_run(expected_output)
    end
  end

  context "when using the include matcher with an array" do
    it "produces the correct output" do
      test = <<~TEST
        expected = ["Marty", "Einie"]
        actual = ["Marty", "Jennifer", "Doc"]
        expect(actual).to include(expected)
      TEST

      expected_output = <<~OUTPUT
        Diff:

        #{
          colored do
            plain_line %(  [)
            plain_line %(    "Marty",)
            plain_line %(    "Jennifer",)
            plain_line %(    "Doc")
            red_line   %(-   "Einie")
            plain_line %(  ])
          end
        }
      OUTPUT

      expect(test).to produce_output_when_run(expected_output)
    end
  end

  context "comparing two hashes with other data structures inside" do
    it "produces the correct output" do
      test = <<~TEST
        expected = {
          customer: {
            person: SuperDiff::Test::Person.new(name: "Marty McFly", age: 17),
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
              options: ["red", "blue", "green"]
            },
            { name: "Chevy 4x4" }
          ]
        }
        actual = {
          customer: {
            person: SuperDiff::Test::Person.new(name: "Marty McFly, Jr.", age: 17),
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
              options: ["red", "blue", "green"]
            },
            { name: "Mattel Hoverboard" }
          ]
        }
        expect(actual).to eq(expected)
      TEST

      expected_output = <<~OUTPUT
        Diff:

        #{
          colored do
            plain_line %(  {)
            plain_line %(    customer: {)
            plain_line %(      person: #<SuperDiff::Test::Person {)
            red_line   %(-       name: "Marty McFly",)
            green_line %(+       name: "Marty McFly, Jr.",)
            plain_line %(        age: 17)
            plain_line %(      }>,)
            plain_line %(      shipping_address: {)
            red_line   %(-       line_1: "123 Main St.",)
            green_line %(+       line_1: "456 Ponderosa Ct.",)
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
            red_line   %(-       name: "Chevy 4x4")
            green_line %(+       name: "Mattel Hoverboard")
            plain_line %(      })
            plain_line %(    ])
            plain_line %(  })
          end
        }
      OUTPUT

      expect(test).to produce_output_when_run(expected_output)
    end
  end

  context "when using the include matcher with a hash" do
    it "produces the correct output" do
      test = <<~TEST
        expected = {
          city: "Hill Valley",
          zip: "90382"
        }
        actual = {
          line_1: "123 Main St.",
          city: "Burbank",
          state: "CA",
          zip: "90210"
        }
        expect(actual).to include(expected)
      TEST

      expected_output = <<~OUTPUT
        Diff:

        #{
          colored do
            plain_line %(  {)
            plain_line %(    line_1: "123 Main St.",)
            red_line   %(-   city: "Hill Valley",)
            green_line %(+   city: "Burbank",)
            plain_line %(    state: "CA",)
            red_line   %(-   zip: "90382")
            green_line %(+   zip: "90210")
            plain_line %(  })
          end
        }
      OUTPUT

      expect(test).to produce_output_when_run(expected_output)
    end
  end

  context "when using the match matcher" do
    context "and the expected value is a partial hash" do
      it "produces the correct output" do
        test = <<~TEST
          expected = a_hash_including(
            city: "Hill Valley",
            zip: "90382"
          )
          actual = {
            line_1: "123 Main St.",
            city: "Burbank",
            state: "CA",
            zip: "90210"
          }
          expect(actual).to match(expected)
        TEST

        expected_output = <<~OUTPUT
          Diff:

          #{
            colored do
              plain_line %(  {)
              plain_line %(    line_1: "123 Main St.",)
              red_line   %(-   city: "Hill Valley",)
              green_line %(+   city: "Burbank",)
              plain_line %(    state: "CA",)
              red_line   %(-   zip: "90382")
              green_line %(+   zip: "90210")
              plain_line %(  })
            end
          }
        OUTPUT

        expect(test).to produce_output_when_run(expected_output)
      end
    end

    context "and the expected value includes a partial hash" do
      context "when the corresponding actual value is a hash" do
        it "produces the correct output" do
          test = <<~TEST
            expected = {
              name: "Marty McFly",
              address: a_hash_including(
                city: "Hill Valley",
                zip: "90382"
              )
            }
            actual = {
              name: "Marty McFly",
              address: {
                line_1: "123 Main St.",
                city: "Burbank",
                state: "CA",
                zip: "90210"
              }
            }
            expect(actual).to match(expected)
          TEST

          expected_output = <<~OUTPUT
            Diff:

            #{
              colored do
                plain_line %(  {)
                plain_line %(    name: "Marty McFly",)
                plain_line %(    address: {)
                plain_line %(      line_1: "123 Main St.",)
                red_line   %(-     city: "Hill Valley",)
                green_line %(+     city: "Burbank",)
                plain_line %(      state: "CA",)
                red_line   %(-     zip: "90382")
                green_line %(+     zip: "90210")
                plain_line %(    })
                plain_line %(  })
              end
            }
          OUTPUT

          expect(test).to produce_output_when_run(expected_output)
        end
      end

      context "when the corresponding actual value is not a hash" do
        it "produces the correct output" do
          test = <<~TEST
            expected = {
              name: "Marty McFly",
              address: a_hash_including(
                city: "Hill Valley",
                zip: "90382"
              )
            }
            actual = {
              name: "Marty McFly",
              address: nil
            }
            expect(actual).to match(expected)
          TEST

          expected_output = <<~OUTPUT
            Diff:

            #{
              colored do
                plain_line %!  {!
                plain_line %!    name: "Marty McFly",!
                red_line   %!-   address: #<a hash including (!
                red_line   %!-     city: "Hill Valley",!
                red_line   %!-     zip: "90382"!
                red_line   %!-   )>!
                green_line %!+   address: nil!
                plain_line %!  }!
              end
            }
          OUTPUT

          expect(test).to produce_output_when_run(expected_output)
        end
      end
    end
  end

  def colored(&block)
    SuperDiff::Tests::Colorizer.call(&block).chomp
  end
end
