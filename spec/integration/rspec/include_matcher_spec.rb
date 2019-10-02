require "spec_helper"

RSpec.describe "Integration with RSpec's #include matcher", type: :integration do
  context "when used against an array" do
    context "that is small" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = ["Marty", "Einie"]
            actual = ["Marty", "Jennifer", "Doc"]
            expect(actual).to include(*expected)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
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

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            values = ["Marty", "Einie"]
            expect(values).not_to include(*values)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(values).not_to include(*values)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|["Marty", "Einie"]|
                plain " not to include "
                red   %|"Marty" and "Einie"|
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

    context "that is large" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
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
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
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

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = [
              "Marty McFly",
              "Doc Brown",
              "Einie",
              "Lorraine McFly"
            ]
            actual = [
              "Marty McFly",
              "Doc Brown",
              "Einie",
              "Biff Tannen",
              "George McFly",
              "Lorraine McFly"
            ]
            expect(actual).not_to include(*expected)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(actual).not_to include(*expected)|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "      Expected "
                green %|["Marty McFly", "Doc Brown", "Einie", "Biff Tannen", "George McFly", "Lorraine McFly"]|
              end

              line do
                plain "not to include "
                red %|"Marty McFly", "Doc Brown", "Einie", and "Lorraine McFly"|
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end
  end

  context "when used against a hash" do
    context "that is small" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = { city: "Hill Valley", state: "CA" }
            actual = { city: "Burbank", zip: "90210" }
            expect(actual).to include(expected)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
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

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = { city: "Burbank" }
            actual = { city: "Burbank", zip: "90210" }
            expect(actual).not_to include(expected)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(actual).not_to include(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|{ city: "Burbank", zip: "90210" }|
                plain " not to include "
                red %|(city: "Burbank")|
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

    context "that is large" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
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
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
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

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = { city: "Hill Valley", state: "CA" }
            actual = { city: "Hill Valley", state: "CA", zip: "90210" }
            expect(actual).not_to include(expected)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(actual).not_to include(expected)|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "      Expected "
                green %|{ city: "Hill Valley", state: "CA", zip: "90210" }|
              end

              line do
                plain "not to include "
                red %|(city: "Hill Valley", state: "CA")|
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end
  end
end
