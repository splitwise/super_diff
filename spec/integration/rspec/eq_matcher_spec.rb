require "spec_helper"

RSpec.describe "Integration with RSpec's #eq matcher", type: :integration do
  context "when comparing two different integers" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = %|expect(1).to eq(42)|
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: snippet,
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

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two different symbols" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = %|expect(:bar).to eq(:foo)|
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: snippet,
          expectation: proc {
            line do
              plain "Expected "
              green %|:bar|
              plain " to eq "
              red %|:foo|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two different single-line strings" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = %|expect("Jennifer").to eq("Marty")|
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect("Jennifer").to eq("Marty")|,
          expectation: proc {
            line do
              plain "Expected "
              green %|"Jennifer"|
              plain " to eq "
              red %|"Marty"|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing a single-line string with a multi-line string" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = "Something entirely different"
          actual = "This is a line\\nAnd that's another line\\n"
          expect(actual).to eq(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
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

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing a multi-line string with a single-line string" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = "This is a line\\nAnd that's another line\\n"
          actual = "Something entirely different"
          expect(actual).to eq(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
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

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two closely different multi-line strings" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = "This is a line\\nAnd that's a line\\nAnd there's a line too\\n"
          actual = "This is a line\\nSomething completely different\\nAnd there's a line too\\n"
          expect(actual).to eq(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
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

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two completely different multi-line strings" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = "This is a line\\nAnd that's a line\\n"
          actual = "Something completely different\\nAnd something else too\\n"
          expect(actual).to eq(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
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

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two arrays with other data structures inside" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST
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
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
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

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two hashes with other data structures inside" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
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
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
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

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two different kinds of custom objects" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
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
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
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

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when comparing two different kinds of non-custom objects" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
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
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output = build_expected_output(
          color_enabled: color_enabled,
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
          in_color(color_enabled).
          removing_object_ids
      end
    end
  end
end
