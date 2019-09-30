require "spec_helper"

RSpec.describe "Integration with RSpec's #have_attributes matcher", type: :integration do
  context "when given a small set of attributes" do
    context "when all of the names are methods on the actual object" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = { name: "b" }
            actual = SuperDiff::Test::Person.new(name: "a", age: 9)
            expect(actual).to have_attributes(expected)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
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

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end

    context "when some of the names are not methods on the actual object" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = { name: "b", foo: "bar" }
            actual = SuperDiff::Test::Person.new(name: "a", age: 9)
            expect(actual).to have_attributes(expected)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
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

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end
  end

  context "when given a large set of attributes" do
    context "when all of the names are methods on the actual object" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
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
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
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

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end

    context "when some of the names are not methods on the actual object" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
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
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
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

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end
  end
end
