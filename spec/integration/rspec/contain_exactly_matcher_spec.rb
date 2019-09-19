require "spec_helper"

RSpec.describe "Integration with RSpec's #contain_exactly matcher", type: :integration do
  context "assuming color is enabled" do
    context "when a few number of values are given" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST)
          expected = ["Einie", "Marty"]
          actual = ["Marty", "Jennifer", "Doc"]
          expect(actual).to contain_exactly(*expected)
        TEST

        expected_output = build_colored_expected_output(
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

          expected_output = build_colored_expected_output(
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

          expected_output = build_colored_expected_output(
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

          expected_output = build_colored_expected_output(
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

  context "if color has been disabled" do
    it "does not include the color in the output" do
      program = make_plain_test_program(<<~TEST, color_enabled: false)
        expected = ["Einie", "Marty"]
        actual = ["Marty", "Jennifer", "Doc"]
        expect(actual).to contain_exactly(*expected)
      TEST

      expected_output = build_uncolored_expected_output(
        snippet: %|expect(actual).to contain_exactly(*expected)|,
        expectation: proc {
          line do
            plain "Expected "
            plain %|["Marty", "Jennifer", "Doc"]|
            plain " to contain exactly "
            plain %|"Einie"|
            plain " and "
            plain %|"Marty"|
            plain "."
          end
        },
        diff: proc {
          plain_line %|  [|
          plain_line %|    "Marty",|
          plain_line %|    "Jennifer",|
          plain_line %|    "Doc",|
          plain_line %|-   "Einie"|
          plain_line %|  ]|
        },
      )

      expect(program).to produce_output_when_run(expected_output)
    end
  end
end
