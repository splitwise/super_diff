require "spec_helper"

RSpec.describe "Integration with RSpec", type: :integration do
  describe "the #eq matcher" do
    context "when comparing two different integers" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expect(1).to eq(42)
        TEST

        expected_output = build_expected_output(
          snippet: %|expect(1).to eq(42)|,
          expectation: proc {
            line do
              plain "Expected "
              green %|1|
              plain " to eq "
              red %|42|
              plain "."
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "when comparing two different symbols" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expect(:bar).to eq(:foo)
        TEST

        expected_output = build_expected_output(
          snippet: %|expect(:bar).to eq(:foo)|,
          expectation: proc {
            line do
              plain "Expected "
              green %|:bar|
              plain " to eq "
              red %|:foo|
              plain "."
            end
          }
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "when comparing two different single-line strings" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expect("Jennifer").to eq("Marty")
        TEST

        expected_output = build_expected_output(
          snippet: %|expect("Jennifer").to eq("Marty")|,
          expectation: proc {
            line do
              plain "Expected "
              green %|"Jennifer"|
              plain " to eq "
              red %|"Marty"|
              plain "."
            end
          }
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "when comparing a single-line string with a multi-line string" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expected = "Something entirely different"
          actual = "This is a line\\nAnd that's another line\\n"
          expect(actual).to eq(expected)
        TEST

        expected_output = build_expected_output(
          snippet: %|expect(actual).to eq(expected)|,
          expectation: proc {
            line do
              plain "Expected "
              green %|"This is a line\\nAnd that's another line\\n"|
              plain " to eq "
              red   %|"Something entirely different"|
              plain "."
            end
          },
          diff: proc {
            red_line   %|- Something entirely different|
            green_line %|+ This is a line\\n|
            green_line %|+ And that's another line\\n|
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "when comparing a multi-line string with a single-line string" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expected = "This is a line\\nAnd that's another line\\n"
          actual = "Something entirely different"
          expect(actual).to eq(expected)
        TEST

        expected_output = build_expected_output(
          snippet: %|expect(actual).to eq(expected)|,
          expectation: proc {
            line do
              plain "Expected "
              green %|"Something entirely different"|
              plain " to eq "
              red %|"This is a line\\nAnd that's another line\\n"|
              plain "."
            end
          },
          diff: proc {
            red_line   %|- This is a line\\n|
            red_line   %|- And that's another line\\n|
            green_line %|+ Something entirely different|
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "when comparing two closely different multi-line strings" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expected = "This is a line\\nAnd that's a line\\nAnd there's a line too\\n"
          actual = "This is a line\\nSomething completely different\\nAnd there's a line too\\n"
          expect(actual).to eq(expected)
        TEST

        expected_output = build_expected_output(
          snippet: %|expect(actual).to eq(expected)|,
          expectation: proc {
            line do
              plain "Expected "
              green %|"This is a line\\nSomething completely different\\nAnd there's a line too\\n"|
            end

            line do
              plain "   to eq "
              red   %|"This is a line\\nAnd that's a line\\nAnd there's a line too\\n"|
            end
          },
          diff: proc {
            plain_line %|  This is a line\\n|
            red_line   %|- And that's a line\\n|
            green_line %|+ Something completely different\\n|
            plain_line %|  And there's a line too\\n|
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "when comparing two completely different multi-line strings" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST)
          expected = "This is a line\\nAnd that's a line\\n"
          actual = "Something completely different\\nAnd something else too\\n"
          expect(actual).to eq(expected)
        TEST

        expected_output = build_expected_output(
          snippet: %|expect(actual).to eq(expected)|,
          expectation: proc {
            line do
              plain "Expected "
              green %|"Something completely different\\nAnd something else too\\n"|
            end

            line do
              plain "   to eq "
              red   %|"This is a line\\nAnd that's a line\\n"|
            end
          },
          diff: proc {
            red_line   %|- This is a line\\n|
            red_line   %|- And that's a line\\n|
            green_line %|+ Something completely different\\n|
            green_line %|+ And something else too\\n|
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "when comparing two arrays with other data structures inside" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST)
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

        expected_output = build_expected_output(
          snippet: %|expect(actual).to eq(expected)|,
          expectation: proc {
            line do
              plain "Expected "
              green %|[[:h2, [:span, [:text, "Goodbye world"]], { id: "hero", class: "header", data: { "sticky" => false, :role => "deprecated", :person => #<SuperDiff::Test::Person name: "Doc", age: 60> } }], :br]|
            end

            line do
              plain "   to eq "
              red   %|[[:h1, [:span, [:text, "Hello world"]], { class: "header", data: { "sticky" => true, :person => #<SuperDiff::Test::Person name: "Marty", age: 60> } }]]|
            end
          },
          diff: proc {
            plain_line %|  [|
            plain_line %|    [|
            red_line   %|-     :h1,|
            green_line %|+     :h2,|
            plain_line %|      [|
            plain_line %|        :span,|
            plain_line %|        [|
            plain_line %|          :text,|
            red_line   %|-         "Hello world"|
            green_line %|+         "Goodbye world"|
            plain_line %|        ]|
            plain_line %|      ],|
            plain_line %|      {|
            green_line %|+       id: "hero",|
            plain_line %|        class: "header",|
            plain_line %|        data: {|
            red_line   %|-         "sticky" => true,|
            green_line %|+         "sticky" => false,|
            green_line %|+         role: "deprecated",|
            plain_line %|          person: #<SuperDiff::Test::Person {|
            red_line   %|-           name: "Marty",|
            green_line %|+           name: "Doc",|
            plain_line %|            age: 60|
            plain_line %|          }>|
            plain_line %|        }|
            plain_line %|      }|
            plain_line %|    ],|
            green_line %|+   :br|
            plain_line %|  ]|
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "when comparing two hashes with other data structures inside" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST)
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

        expected_output = build_expected_output(
          snippet: %|expect(actual).to eq(expected)|,
          expectation: proc {
            line do
              plain "Expected "
              green %|{ customer: { person: #<SuperDiff::Test::Person name: "Marty McFly, Jr.", age: 17>, shipping_address: { line_1: "456 Ponderosa Ct.", city: "Hill Valley", state: "CA", zip: "90382" } }, items: [{ name: "Fender Stratocaster", cost: 100000, options: ["red", "blue", "green"] }, { name: "Mattel Hoverboard" }] }|
            end

            line do
              plain "   to eq "
              red   %|{ customer: { person: #<SuperDiff::Test::Person name: "Marty McFly", age: 17>, shipping_address: { line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" } }, items: [{ name: "Fender Stratocaster", cost: 100000, options: ["red", "blue", "green"] }, { name: "Chevy 4x4" }] }|
            end
          },
          diff: proc {
            plain_line %|  {|
            plain_line %|    customer: {|
            plain_line %|      person: #<SuperDiff::Test::Person {|
            red_line   %|-       name: "Marty McFly",|
            green_line %|+       name: "Marty McFly, Jr.",|
            plain_line %|        age: 17|
            plain_line %|      }>,|
            plain_line %|      shipping_address: {|
            red_line   %|-       line_1: "123 Main St.",|
            green_line %|+       line_1: "456 Ponderosa Ct.",|
            plain_line %|        city: "Hill Valley",|
            plain_line %|        state: "CA",|
            plain_line %|        zip: "90382"|
            plain_line %|      }|
            plain_line %|    },|
            plain_line %|    items: [|
            plain_line %|      {|
            plain_line %|        name: "Fender Stratocaster",|
            plain_line %|        cost: 100000,|
            plain_line %|        options: [|
            plain_line %|          "red",|
            plain_line %|          "blue",|
            plain_line %|          "green"|
            plain_line %|        ]|
            plain_line %|      },|
            plain_line %|      {|
            red_line   %|-       name: "Chevy 4x4"|
            green_line %|+       name: "Mattel Hoverboard"|
            plain_line %|      }|
            plain_line %|    ]|
            plain_line %|  }|
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "when comparing two different kinds of custom objects" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expected = SuperDiff::Test::Person.new(
            name: "Marty",
            age: 31,
          )
          actual = SuperDiff::Test::Customer.new(
            name: "Doc",
            shipping_address: :some_shipping_address,
            phone: "1234567890",
          )
          expect(actual).to eq(expected)
        TEST

        expected_output = build_expected_output(
          snippet: %|expect(actual).to eq(expected)|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain "Expected "
              green %|#<SuperDiff::Test::Customer name: "Doc", shipping_address: :some_shipping_address, phone: "1234567890">|
            end

            line do
              plain "   to eq "
              red %|#<SuperDiff::Test::Person name: "Marty", age: 31>|
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "when comparing two different kinds of non-custom objects" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
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
          expect(actual).to eq(expected)
        TEST

        expected_output = build_expected_output(
          snippet: %|expect(actual).to eq(expected)|,
          newline_before_expectation: true,
          expectation: proc {
            if SuperDiff::Test.jruby?
            else
              line do
                plain "Expected "
                green %|#<SuperDiff::Test::Player @handle="mcmire", @character="Jon", @inventory=["sword"], @shields=11.4, @health=4, @ultimate=true>|
              end

              line do
                plain "   to eq "
                red %|#<SuperDiff::Test::Item @name="camera", @quantity=3>|
              end
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          first_replacing(/#<([\w:]+):0x[a-z0-9]+ /, '#<\1 ')
      end
    end
  end

  describe "the #include matcher" do
    context "when used against an array" do
      context "that is small" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = ["Marty", "Einie"]
            actual = ["Marty", "Jennifer", "Doc"]
            expect(actual).to include(*expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to include(*expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|["Marty", "Jennifer", "Doc"]|
                plain " to include "
                red   %|"Einie"|
                plain "."
              end
            },
            diff: proc {
              plain_line %|  [|
              plain_line %|    "Marty",|
              plain_line %|    "Jennifer",|
              # plain_line %|    "Doc",|   # FIXME
              plain_line %|    "Doc"|
              red_line   %|-   "Einie"|
              plain_line %|  ]|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "that is large" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = [
              "Marty McFly",
              "Doc Brown",
              "Einie",
              "Biff Tannen",
              "George McFly",
              "Lorraine McFly"
            ]
            actual = [
              "Marty McFly",
              "Doc Brown",
              "Einie",
              "Lorraine McFly"
            ]
            expect(actual).to include(*expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to include(*expected)|,
            expectation: proc {
              line do
                plain "  Expected "
                green %|["Marty McFly", "Doc Brown", "Einie", "Lorraine McFly"]|
              end

              line do
                plain "to include "
                red %|"Biff Tannen" and "George McFly"|
              end
            },
            diff: proc {
              plain_line %|  [|
              plain_line %|    "Marty McFly",|
              plain_line %|    "Doc Brown",|
              plain_line %|    "Einie",|
              # plain_line %|    "Lorraine McFly",|   # FIXME
              plain_line %|    "Lorraine McFly"|
              red_line   %|-   "Biff Tannen",|
              red_line   %|-   "George McFly"|
              plain_line %|  ]|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end

    context "when used against a hash" do
      context "that is small" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = { city: "Hill Valley", state: "CA" }
            actual = { city: "Burbank", zip: "90210" }
            expect(actual).to include(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to include(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|{ city: "Burbank", zip: "90210" }|
                plain " to include "
                red %|(city: "Hill Valley", state: "CA")|
                plain "."
              end
            },
            diff: proc {
              plain_line %|  {|
              red_line   %|-   city: "Hill Valley",|
              green_line %|+   city: "Burbank",|
              # FIXME
              # plain_line %|    zip: "90210",|
              plain_line %|    zip: "90210"|
              red_line   %|-   state: "CA"|
              plain_line %|  }|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "that is large" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = {
              city: "Hill Valley",
              zip: "90382"
            }
            actual = {
              city: "Burbank",
              state: "CA",
              zip: "90210"
            }
            expect(actual).to include(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to include(expected)|,
            expectation: proc {
              line do
                plain "  Expected "
                green %|{ city: "Burbank", state: "CA", zip: "90210" }|
              end

              line do
                plain "to include "
                red %|(city: "Hill Valley", zip: "90382")|
              end
            },
            diff: proc {
              plain_line %|  {|
              red_line   %|-   city: "Hill Valley",|
              green_line %|+   city: "Burbank",|
              plain_line %|    state: "CA",|
              red_line   %|-   zip: "90382"|
              green_line %|+   zip: "90210"|
              plain_line %|  }|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end
  end

  describe "the #contain_exactly matcher" do
    context "when a few number of values are given" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST)
          expected = ["Einie", "Marty"]
          actual = ["Marty", "Jennifer", "Doc"]
          expect(actual).to contain_exactly(*expected)
        TEST

        expected_output = build_expected_output(
          snippet: %|expect(actual).to contain_exactly(*expected)|,
          expectation: proc {
            line do
              plain "Expected "
              green %|["Marty", "Jennifer", "Doc"]|
              plain " to contain exactly "
              red   %|"Einie"|
              plain " and "
              red   %|"Marty"|
              plain "."
            end
          },
          diff: proc {
            plain_line %|  [|
            plain_line %|    "Marty",|
            plain_line %|    "Jennifer",|
            plain_line %|    "Doc",|
            red_line   %|-   "Einie"|
            plain_line %|  ]|
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "when a large number of values are given" do
      context "and they are only simple strings" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = [
              "Doc Brown",
              "Marty McFly",
              "Biff Tannen",
              "George McFly",
              "Lorraine McFly"
            ]
            actual = [
              "Marty McFly",
              "Doc Brown",
              "Einie",
              "Lorraine McFly"
            ]
            expect(actual).to contain_exactly(*expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to contain_exactly(*expected)|,
            expectation: proc {
              line do
                plain "          Expected "
                green %|["Marty McFly", "Doc Brown", "Einie", "Lorraine McFly"]|
              end

              line do
                plain "to contain exactly "
                red %|"Doc Brown"|
                plain ", "
                red %|"Marty McFly"|
                plain ", "
                red %|"Biff Tannen"|
                plain ", "
                red %|"George McFly"|
                plain " and "
                red %|"Lorraine McFly"|
              end
            },
            diff: proc {
              plain_line %|  [|
              plain_line %|    "Marty McFly",|
              plain_line %|    "Doc Brown",|
              plain_line %|    "Einie",|
              plain_line %|    "Lorraine McFly",|
              red_line   %|-   "Biff Tannen",|
              red_line   %|-   "George McFly"|
              plain_line %|  ]|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "and some of them are regexen" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = [
              / Brown$/,
              "Marty McFly",
              "Biff Tannen",
              /Georg McFly/,
              /Lorrain McFly/
            ]
            actual = [
              "Marty McFly",
              "Doc Brown",
              "Einie",
              "Lorraine McFly"
            ]
            expect(actual).to contain_exactly(*expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to contain_exactly(*expected)|,
            expectation: proc {
              line do
                plain "          Expected "
                green %|["Marty McFly", "Doc Brown", "Einie", "Lorraine McFly"]|
              end

              line do
                plain "to contain exactly "
                red %|/ Brown$/|
                plain ", "
                red %|"Marty McFly"|
                plain ", "
                red %|"Biff Tannen"|
                plain ", "
                red %|/Georg McFly/|
                plain " and "
                red %|/Lorrain McFly/|
              end
            },
            diff: proc {
              plain_line %|  [|
              plain_line %|    "Marty McFly",|
              plain_line %|    "Doc Brown",|
              plain_line %|    "Einie",|
              plain_line %|    "Lorraine McFly",|
              red_line   %|-   "Biff Tannen",|
              red_line   %|-   /Georg McFly/,|
              red_line   %|-   /Lorrain McFly/|
              plain_line %|  ]|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "and some of them are fuzzy objects" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = [
              a_hash_including(foo: "bar"),
              a_collection_containing_exactly("zing"),
              an_object_having_attributes(baz: "qux"),
            ]
            actual = [
              { foo: "bar" },
              double(baz: "qux"),
              { blargh: "riddle" }
            ]
            expect(actual).to contain_exactly(*expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to contain_exactly(*expected)|,
            expectation: proc {
              line do
                plain "          Expected "
                green %|[{ foo: "bar" }, #<Double (anonymous)>, { blargh: "riddle" }]|
              end

              line do
                plain "to contain exactly "
                red %|#<a hash including (foo: "bar")>|
                plain ", "
                red %|#<a collection containing exactly ("zing")>|
                plain " and "
                red %|#<an object having attributes (baz: "qux")>|
              end
            },
            diff: proc {
              plain_line %|  [|
              plain_line %|    {|
              plain_line %|      foo: "bar"|
              plain_line %|    },|
              plain_line %|    #<Double (anonymous)>,|
              plain_line %|    {|
              plain_line %|      blargh: "riddle"|
              plain_line %|    },|
              red_line   %|-   #<a collection containing exactly (|
              red_line   %|-     "zing"|
              red_line   %|-   )>|
              plain_line %|  ]|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end
  end

  describe "the #match matcher" do
    context "when the expected value is a partial hash" do
      context "that is small" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = a_hash_including(city: "Hill Valley")
            actual = { city: "Burbank" }
            expect(actual).to match(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to match(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|{ city: "Burbank" }|
                plain " to match "
                red %|#<a hash including (city: "Hill Valley")>|
                plain "."
              end
            },
            diff: proc {
              plain_line %|  {|
              red_line   %|-   city: "Hill Valley"|
              green_line %|+   city: "Burbank"|
              plain_line %|  }|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "that is large" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
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

          expected_output = build_expected_output(
            snippet: %|expect(actual).to match(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|{ line_1: "123 Main St.", city: "Burbank", state: "CA", zip: "90210" }|
              end

              line do
                plain "to match "
                red %|#<a hash including (city: "Hill Valley", zip: "90382")>|
              end
            },
            diff: proc {
              plain_line %|  {|
              plain_line %|    line_1: "123 Main St.",|
              red_line   %|-   city: "Hill Valley",|
              green_line %|+   city: "Burbank",|
              plain_line %|    state: "CA",|
              red_line   %|-   zip: "90382"|
              green_line %|+   zip: "90210"|
              plain_line %|  }|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end

    context "when the expected value includes a partial hash" do
      context "and the corresponding actual value is a hash" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
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

          expected_output = build_expected_output(
            snippet: %|expect(actual).to match(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|{ name: "Marty McFly", address: { line_1: "123 Main St.", city: "Burbank", state: "CA", zip: "90210" } }|
              end

              line do
                plain "to match "
                red   %|{ name: "Marty McFly", address: #<a hash including (city: "Hill Valley", zip: "90382")> }|
              end
            },
            diff: proc {
              plain_line %|  {|
              plain_line %|    name: "Marty McFly",|
              plain_line %|    address: {|
              plain_line %|      line_1: "123 Main St.",|
              red_line   %|-     city: "Hill Valley",|
              green_line %|+     city: "Burbank",|
              plain_line %|      state: "CA",|
              red_line   %|-     zip: "90382"|
              green_line %|+     zip: "90210"|
              plain_line %|    }|
              plain_line %|  }|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "and the corresponding actual value is not a hash" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
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

          expected_output = build_expected_output(
            snippet: %|expect(actual).to match(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|{ name: "Marty McFly", address: nil }|
              end

              line do
                plain "to match "
                red   %|{ name: "Marty McFly", address: #<a hash including (city: "Hill Valley", zip: "90382")> }|
              end
            },
            diff: proc {
              plain_line %!  {!
              plain_line %!    name: "Marty McFly",!
              red_line   %!-   address: #<a hash including (!
              red_line   %!-     city: "Hill Valley",!
              red_line   %!-     zip: "90382"!
              red_line   %!-   )>!
              green_line %!+   address: nil!
              plain_line %!  }!
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end

    context "when the expected value is a partial array" do
      context "that is small" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = a_collection_including("a")
            actual = ["b"]
            expect(actual).to match(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to match(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|["b"]|
                plain " to match "
                red   %|#<a collection including ("a")>|
                plain "."
              end
            },
            diff: proc {
              plain_line %|  [|
              plain_line %|    "b"|
              # red_line   %|-   "a",|   # FIXME
              red_line   %|-   "a"|
              plain_line %|  ]|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "that is large" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = a_collection_including("milk", "bread")
            actual = ["milk", "toast", "eggs", "cheese", "English muffins"]
            expect(actual).to match(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to match(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|["milk", "toast", "eggs", "cheese", "English muffins"]|
              end

              line do
                plain "to match "
                red   %|#<a collection including ("milk", "bread")>|
              end
            },
            diff: proc {
              plain_line %|  [|
              plain_line %|    "milk",|
              plain_line %|    "toast",|
              plain_line %|    "eggs",|
              plain_line %|    "cheese",|
              # plain_line %|    "English muffins",|  # FIXME
              plain_line %|    "English muffins"|
              red_line   %|-   "bread"|
              plain_line %|  ]|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end

    context "when the expected value includes a partial array" do
      context "and the corresponding actual value is an array" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = {
              name: "shopping list",
              contents: a_collection_including("milk", "bread")
            }
            actual = {
              name: "shopping list",
              contents: ["milk", "toast", "eggs"]
            }
            expect(actual).to match(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to match(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|{ name: "shopping list", contents: ["milk", "toast", "eggs"] }|
              end

              line do
                plain "to match "
                red   %|{ name: "shopping list", contents: #<a collection including ("milk", "bread")> }|
              end
            },
            diff: proc {
              plain_line %|  {|
              plain_line %|    name: "shopping list",|
              plain_line %|    contents: [|
              plain_line %|      "milk",|
              plain_line %|      "toast",|
              # plain_line %|      "eggs",|     # FIXME
              plain_line %|      "eggs"|
              red_line   %|-     "bread"|
              plain_line %|    ]|
              plain_line %|  }|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "when the corresponding actual value is not an array" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = {
              name: "shopping list",
              contents: a_collection_including("milk", "bread")
            }
            actual = {
              name: "shopping list",
              contents: nil
            }
            expect(actual).to match(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to match(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|{ name: "shopping list", contents: nil }|
              end

              line do
                plain "to match "
                red   %|{ name: "shopping list", contents: #<a collection including ("milk", "bread")> }|
              end
            },
            diff: proc {
              plain_line %!  {!
              plain_line %!    name: "shopping list",!
              red_line   %!-   contents: #<a collection including (!
              red_line   %!-     "milk",!
              red_line   %!-     "bread"!
              red_line   %!-   )>!
              green_line %!+   contents: nil!
              plain_line %!  }!
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end

    context "when the expected value is a partial object" do
      context "that is small" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = an_object_having_attributes(
              name: "b"
            )
            actual = A.new("a")
            expect(actual).to match(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to match(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|#<A name: "a">|
                plain " to match "
                red   %|#<an object having attributes (name: "b")>|
                plain "."
              end
            },
            diff: proc {
              plain_line %|  #<A {|
              # red_line   %|-   name: "b",|  # FIXME
              red_line   %|-   name: "b"|
              green_line %|+   name: "a"|
              plain_line %|  }>|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "that is large" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = an_object_having_attributes(
              line_1: "123 Main St.",
              city: "Oakland",
              zip: "91234",
              state: "CA",
              something_else: "blah"
            )
            actual = SuperDiff::Test::ShippingAddress.new(
              line_1: "456 Ponderosa Ct.",
              line_2: nil,
              city: "Hill Valley",
              state: "CA",
              zip: "90382"
            )
            expect(actual).to match(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to match(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|#<SuperDiff::Test::ShippingAddress line_1: "456 Ponderosa Ct.", line_2: nil, city: "Hill Valley", state: "CA", zip: "90382">|
              end

              line do
                plain "to match "
                red   %|#<an object having attributes (line_1: "123 Main St.", city: "Oakland", zip: "91234", state: "CA", something_else: "blah")>|
              end
            },
            diff: proc {
              plain_line %|  #<SuperDiff::Test::ShippingAddress {|
              red_line   %|-   line_1: "123 Main St.",|
              green_line %|+   line_1: "456 Ponderosa Ct.",|
              plain_line %|    line_2: nil,|
              red_line   %|-   city: "Oakland",|
              green_line %|+   city: "Hill Valley",|
              plain_line %|    state: "CA",|
              # red_line   %|-   zip: "91234",|  # FIXME
              # green_line %|+   zip: "90382",|  # FIXME
              red_line   %|-   zip: "91234"|
              green_line %|+   zip: "90382"|
              red_line   %|-   something_else: "blah"|
              plain_line %|  }>|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end

    context "when the expected value includes a partial object" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST)
          expected = {
            name: "Marty McFly",
            shipping_address: an_object_having_attributes(
              line_1: "123 Main St.",
              city: "Oakland",
              state: "CA",
              zip: "91234",
              something_else: "blah"
            )
          }
          actual = {
            name: "Marty McFly",
            shipping_address: SuperDiff::Test::ShippingAddress.new(
              line_1: "456 Ponderosa Ct.",
              line_2: nil,
              city: "Hill Valley",
              state: "CA",
              zip: "90382"
            )
          }
          expect(actual).to match(expected)
        TEST

        expected_output = build_expected_output(
          snippet: %|expect(actual).to match(expected)|,
          expectation: proc {
            line do
              plain "Expected "
              green %|{ name: "Marty McFly", shipping_address: #<SuperDiff::Test::ShippingAddress line_1: "456 Ponderosa Ct.", line_2: nil, city: "Hill Valley", state: "CA", zip: "90382"> }|
            end

            line do
              plain "to match "
              red   %|{ name: "Marty McFly", shipping_address: #<an object having attributes (line_1: "123 Main St.", city: "Oakland", state: "CA", zip: "91234", something_else: "blah")> }|
            end
          },
          diff: proc {
            plain_line %|  {|
            plain_line %|    name: "Marty McFly",|
            plain_line %|    shipping_address: #<SuperDiff::Test::ShippingAddress {|
            red_line   %|-     line_1: "123 Main St.",|
            green_line %|+     line_1: "456 Ponderosa Ct.",|
            plain_line %|      line_2: nil,|
            red_line   %|-     city: "Oakland",|
            green_line %|+     city: "Hill Valley",|
            plain_line %|      state: "CA",|
            # red_line   %|-     zip: "91234",|  # FIXME
            red_line   %|-     zip: "91234"|
            green_line %|+     zip: "90382"|
            red_line   %|-     something_else: "blah"|
            plain_line %|    }>|
            plain_line %|  }|
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "when the expected value is an order-independent array" do
      context "that is small" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = a_collection_containing_exactly("a")
            actual = ["b"]
            expect(actual).to match(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to match(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|["b"]|
                plain " to match "
                red   %|#<a collection containing exactly ("a")>|
                plain "."
              end
            },
            diff: proc {
              plain_line %|  [|
              plain_line %|    "b",|
              red_line   %|-   "a"|
              plain_line %|  ]|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "that is large" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = a_collection_containing_exactly("milk", "bread")
            actual = ["milk", "toast", "eggs", "cheese", "English muffins"]
            expect(actual).to match(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to match(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|["milk", "toast", "eggs", "cheese", "English muffins"]|
              end

              line do
                plain "to match "
                red   %|#<a collection containing exactly ("milk", "bread")>|
              end
            },
            diff: proc {
              plain_line %|  [|
              plain_line %|    "milk",|
              plain_line %|    "toast",|
              plain_line %|    "eggs",|
              plain_line %|    "cheese",|
              plain_line %|    "English muffins",|
              red_line   %|-   "bread"|
              plain_line %|  ]|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end

    context "when the expected value includes an order-independent array" do
      context "and the corresponding actual value is an array" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = {
              name: "shopping list",
              contents: a_collection_containing_exactly("milk", "bread")
            }
            actual = {
              name: "shopping list",
              contents: ["milk", "toast", "eggs"]
            }
            expect(actual).to match(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to match(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|{ name: "shopping list", contents: ["milk", "toast", "eggs"] }|
              end

              line do
                plain "to match "
                red   %|{ name: "shopping list", contents: #<a collection containing exactly ("milk", "bread")> }|
              end
            },
            diff: proc {
              plain_line %|  {|
              plain_line %|    name: "shopping list",|
              plain_line %|    contents: [|
              plain_line %|      "milk",|
              plain_line %|      "toast",|
              plain_line %|      "eggs",|
              red_line   %|-     "bread"|
              plain_line %|    ]|
              plain_line %|  }|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "when the corresponding actual value is not an array" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = {
              name: "shopping list",
              contents: a_collection_containing_exactly("milk", "bread")
            }
            actual = {
              name: "shopping list",
              contents: nil
            }
            expect(actual).to match(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to match(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|{ name: "shopping list", contents: nil }|
              end

              line do
                plain "to match "
                red   %|{ name: "shopping list", contents: #<a collection containing exactly ("milk", "bread")> }|
              end
            },
            diff: proc {
              plain_line %!  {!
              plain_line %!    name: "shopping list",!
              red_line   %!-   contents: #<a collection containing exactly (!
              red_line   %!-     "milk",!
              red_line   %!-     "bread"!
              red_line   %!-   )>!
              green_line %!+   contents: nil!
              plain_line %!  }!
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end
  end

  describe "the #have_attributes matcher" do
    context "when given a small set of attributes" do
      context "when all of the names are methods on the actual object" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = { name: "b" }
            actual = SuperDiff::Test::Person.new(name: "a", age: 9)
            expect(actual).to have_attributes(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to have_attributes(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|#<SuperDiff::Test::Person name: "a", age: 9>|
                plain " to have attributes "
                red   %|(name: "b")|
                plain "."
              end
            },
            diff: proc {
              plain_line %|  #<SuperDiff::Test::Person {|
              # red_line   %|-   name: "b",|  # FIXME
              red_line   %|-   name: "b"|
              green_line %|+   name: "a",|
              plain_line %|    age: 9|
              plain_line %|  }>|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "when some of the names are not methods on the actual object" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = { name: "b", foo: "bar" }
            actual = SuperDiff::Test::Person.new(name: "a", age: 9)
            expect(actual).to have_attributes(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to have_attributes(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green  %|#<SuperDiff::Test::Person name: "a", age: 9>|
                plain " to respond to "
                red  %|:foo|
                plain " with "
                red  %|0|
                plain " arguments."
              end
            },
            diff: proc {
              plain_line %|  #<SuperDiff::Test::Person {|
              plain_line %|    name: "a",|
              # plain_line %|    age: 9,|  # FIXME
              plain_line %|    age: 9|
              # red_line   %|-   foo: "bar",|  # FIXME
              red_line   %|-   foo: "bar"|
              plain_line %|  }>|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end

    context "when given a large set of attributes" do
      context "when all of the names are methods on the actual object" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = {
              line_1: "123 Main St.",
              city: "Oakland",
              state: "CA",
              zip: "91234"
            }
            actual = SuperDiff::Test::ShippingAddress.new(
              line_1: "456 Ponderosa Ct.",
              line_2: nil,
              city: "Hill Valley",
              state: "CA",
              zip: "90382"
            )
            expect(actual).to have_attributes(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to have_attributes(expected)|,
            expectation: proc {
              line do
                plain "          Expected "
                green %|#<SuperDiff::Test::ShippingAddress line_1: "456 Ponderosa Ct.", line_2: nil, city: "Hill Valley", state: "CA", zip: "90382">|
              end

              line do
                plain "to have attributes "
                red   %|(line_1: "123 Main St.", city: "Oakland", state: "CA", zip: "91234")|
              end
            },
            diff: proc {
              plain_line %|  #<SuperDiff::Test::ShippingAddress {|
              red_line   %|-   line_1: "123 Main St.",|
              green_line %|+   line_1: "456 Ponderosa Ct.",|
              plain_line %|    line_2: nil,|
              red_line   %|-   city: "Oakland",|
              green_line %|+   city: "Hill Valley",|
              plain_line %|    state: "CA",|
              # red_line   %|-   zip: "91234",|  # FIXME
              red_line   %|-   zip: "91234"|
              green_line %|+   zip: "90382"|
              plain_line %|  }>|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "when some of the names are not methods on the actual object" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expected = {
              line_1: "123 Main St.",
              city: "Oakland",
              state: "CA",
              zip: "91234",
              foo: "bar",
              baz: "qux"
            }
            actual = SuperDiff::Test::ShippingAddress.new(
              line_1: "456 Ponderosa Ct.",
              line_2: nil,
              city: "Hill Valley",
              state: "CA",
              zip: "90382"
            )
            expect(actual).to have_attributes(expected)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(actual).to have_attributes(expected)|,
            expectation: proc {
              line do
                plain "     Expected "
                green %|#<SuperDiff::Test::ShippingAddress line_1: "456 Ponderosa Ct.", line_2: nil, city: "Hill Valley", state: "CA", zip: "90382">|
              end

              line do
                plain "to respond to "
                red  %|:foo|
                plain " and "
                red %|:baz|
                plain " with "
                red %|0|
                plain " arguments"
              end
            },
            diff: proc {
              plain_line %|  #<SuperDiff::Test::ShippingAddress {|
              plain_line %|    line_1: "456 Ponderosa Ct.",|
              plain_line %|    line_2: nil,|
              plain_line %|    city: "Hill Valley",|
              plain_line %|    state: "CA",|
              # plain_line %|    zip: "90382",|  # FIXME
              plain_line %|    zip: "90382"|
              # red_line   %|-   foo: "bar",|  # FIXME
              red_line   %|-   foo: "bar"|
              red_line   %|-   baz: "qux"|
              plain_line %|  }>|
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end
  end

  describe "the #raise_error matcher" do
    context "given only an exception class" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expect { raise StandardError.new('boo') }.to raise_error(RuntimeError)
        TEST

        expected_output = build_expected_output(
          snippet: %|expect { raise StandardError.new('boo') }.to raise_error(RuntimeError)|,
          expectation: proc {
            line do
              plain "Expected raised exception "
              green %|#<StandardError "boo">|
              plain " to match "
              red %|#<RuntimeError>|
              plain "."
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "with only a message (and assuming a RuntimeError)" do
      context "when the message is short" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expect { raise 'boo' }.to raise_error('hell')
          TEST

          expected_output = build_expected_output(
            snippet: %|expect { raise 'boo' }.to raise_error('hell')|,
            expectation: proc {
              line do
                plain "Expected raised exception "
                green %|#<RuntimeError "boo">|
                plain " to match "
                red %|#<Exception "hell">|
                plain "."
              end
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "when the message is long" do
        context "but contains no line breaks" do
          it "produces the correct output" do
            program = make_plain_test_program(<<~TEST)
              actual_message = "some really really really long message"
              expected_message = "whatever"
              expect { raise(actual_message) }.to raise_error(expected_message)
            TEST

            expected_output = build_expected_output(
              snippet: %|expect { raise(actual_message) }.to raise_error(expected_message)|,
              newline_before_expectation: true,
              expectation: proc {
                line do
                  plain "Expected raised exception "
                  green %|#<RuntimeError "some really really really long message">|
                end

                line do
                  plain "                 to match "
                  red %|#<Exception "whatever">|
                end
              },
            )

            expect(program).to produce_output_when_run(expected_output)
          end
        end

        context "but contains line breaks" do
          it "produces the correct output" do
            program = make_plain_test_program(<<~TEST)
              actual_message = <<~MESSAGE.rstrip
                This is fun
                So is this
              MESSAGE
              expected_message = <<~MESSAGE.rstrip
                This is fun
                And so is this
              MESSAGE
              expect { raise(actual_message) }.to raise_error(expected_message)
            TEST

            expected_output = build_expected_output(
              snippet: %|expect { raise(actual_message) }.to raise_error(expected_message)|,
              expectation: proc {
                line do
                  plain "Expected raised exception "
                  green %|#<RuntimeError "This is fun\\nSo is this">|
                end

                line do
                  plain "                 to match "
                  red %|#<Exception "This is fun\\nAnd so is this">|
                end
              },
              diff: proc {
                plain_line %|  This is fun\\n|
                red_line   %|- And so is this|
                green_line %|+ So is this|
              },
            )

            expect(program).to produce_output_when_run(expected_output)
          end
        end
      end
    end

    context "with both an exception and a message" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST)
          block = -> { raise StandardError.new('a') }
          expect(&block).to raise_error(RuntimeError, 'b')
        TEST

        expected_output = build_expected_output(
          snippet: %|expect(&block).to raise_error(RuntimeError, 'b')|,
          expectation: proc {
            line do
              plain "Expected raised exception "
              green %|#<StandardError "a">|
              plain " to match "
              red %|#<RuntimeError "b">|
              plain "."
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end
  end

  describe "the #respond_to matcher" do
    context "without any qualifiers" do
      context "when a few number of methods are specified" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expect(double).to respond_to(:foo)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(double).to respond_to(:foo)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|#<Double (anonymous)>|
                plain " to respond to "
                red %|:foo|
                plain "."
              end
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "when a large number of methods are specified" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz)|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "     Expected "
                green %|#<Double :something_really_long>|
              end

              line do
                plain "to respond to "
                red %|:foo|
                plain ", "
                red %|:bar|
                plain " and "
                red %|:baz|
              end
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end

    context "qualified with #with + #arguments" do
      context "when a few number of methods are specified" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expect(double).to respond_to(:foo).with(3).arguments
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(double).to respond_to(:foo).with(3).arguments|,
            expectation: proc {
              line do
                plain "Expected "
                green %|#<Double (anonymous)>|
                plain " to respond to "
                red %|:foo|
                plain " with "
                red %|3|
                plain " arguments."
              end
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "when a large number of methods are specified" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with(3).arguments
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with(3).arguments|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "     Expected "
                green %|#<Double :something_really_long>|
              end

              line do
                plain "to respond to "
                red %|:foo|
                plain ", "
                red %|:bar|
                plain " and "
                red %|:baz|
                plain " with "
                red %|3|
                plain " arguments"
              end
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end

    context "qualified with #with_keywords" do
      context "when a few number of methods are specified" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expect(double).to respond_to(:foo).with_keywords(:bar)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(double).to respond_to(:foo).with_keywords(:bar)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|#<Double (anonymous)>|
                plain " to respond to "
                red %|:foo|
                plain " with keyword "
                red %|:bar|
                plain "."
              end
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "when a large number of methods are specified" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_keywords(:qux, :blargh)
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_keywords(:qux, :blargh)|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "     Expected "
                green %|#<Double :something_really_long>|
              end

              line do
                plain "to respond to "
                red %|:foo|
                plain ", "
                red %|:bar|
                plain " and "
                red %|:baz|
                plain " with keywords "
                red %|:qux|
                plain " and "
                red %|:blargh|
              end
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end

    context "qualified with #with_any_keywords" do
      context "when a few number of methods are specified" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expect(double).to respond_to(:foo).with_any_keywords
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(double).to respond_to(:foo).with_any_keywords|,
            expectation: proc {
              line do
                plain "Expected "
                green %|#<Double (anonymous)>|
                plain " to respond to "
                red %|:foo|
                plain " with "
                red %|any|
                plain " keywords."
              end
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "when a large number of methods are specified" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_any_keywords
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_any_keywords|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "     Expected "
                green %|#<Double :something_really_long>|
              end

              line do
                plain "to respond to "
                red %|:foo|
                plain ", "
                red %|:bar|
                plain " and "
                red %|:baz|
                plain " with "
                red %|any|
                plain " keywords "
              end
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end

    context "qualified with #with_unlimited_arguments" do
      context "when a few number of methods are specified" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expect(double).to respond_to(:foo).with_unlimited_arguments
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(double).to respond_to(:foo).with_unlimited_arguments|,
            expectation: proc {
              line do
                plain "Expected "
                green %|#<Double (anonymous)>|
                plain " to respond to "
                red %|:foo|
                plain " with "
                red %|unlimited|
                plain " arguments."
              end
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "when a large number of methods are specified" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_unlimited_arguments
          TEST

          expected_output = build_expected_output(
            snippet: %|expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_unlimited_arguments|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "     Expected "
                green %|#<Double :something_really_long>|
              end

              line do
                plain "to respond to "
                red %|:foo|
                plain ", "
                red %|:bar|
                plain " and "
                red %|:baz|
                plain " with "
                red %|unlimited|
                plain " arguments"
              end
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end

    context "qualified with #with_arbitrary_keywords + #with_unlimited_arguments" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST)
          expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_any_keywords.with_unlimited_arguments
        TEST

        expected_output = build_expected_output(
          snippet: %|expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_any_keywords.with_unlimited_arguments|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain "     Expected "
              green %|#<Double :something_really_long>|
            end

            line do
              plain "to respond to "
              red %|:foo|
              plain ", "
              red %|:bar|
              plain " and "
              red %|:baz|
              plain " with "
              red %|any|
              plain " keywords and "
              red %|unlimited|
              plain " arguments"
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "qualified with #with_keywords + #with_unlimited_arguments" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST)
          expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_keywords(:qux, :blargh).with_unlimited_arguments
        TEST

        expected_output = build_expected_output(
          snippet: %|expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_keywords(:qux, :blargh).with_unlimited_arguments|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain "     Expected "
              green %|#<Double :something_really_long>|
            end

            line do
              plain "to respond to "
              red %|:foo|
              plain ", "
              red %|:bar|
              plain " and "
              red %|:baz|
              plain " with keywords "
              red %|:qux|
              plain " and "
              red %|:blargh|
              plain " and "
              red %|unlimited|
              plain " arguments"
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end
  end
end
