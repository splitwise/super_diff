require "spec_helper"

RSpec.describe "Integration with RSpec's #have_attributes matcher", type: :integration do
  context "when given a small set of attributes" do
    context "when all of the names are methods on the actual object" do
      it "produces the correct output when used in the positive" do
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
                beta %|#<SuperDiff::Test::Person name: "a", age: 9>|
                plain " to have attributes "
                alpha %|(name: "b")|
                plain "."
              end
            },
            diff: proc {
              plain_line %|  #<SuperDiff::Test::Person {|
              # alpha_line %|-   name: "b",|  # FIXME
              alpha_line %|-   name: "b"|
              beta_line %|+   name: "a",|
              plain_line %|    age: 9|
              plain_line %|  }>|
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end

      it "produces the correct output when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = { name: "a" }
            actual = SuperDiff::Test::Person.new(name: "a", age: 9)
            expect(actual).not_to have_attributes(expected)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(actual).not_to have_attributes(expected)|,
            expectation: proc {
              line do
                plain "Expected "
                beta %|#<SuperDiff::Test::Person name: "a", age: 9>|
                plain " not to have attributes "
                alpha %|(name: "a")|
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
                beta %|#<SuperDiff::Test::Person name: "a", age: 9>|
                plain " to respond to "
                alpha %|:foo|
                plain " with "
                alpha %|0|
                plain " arguments."
              end
            },
            diff: proc {
              plain_line %|  #<SuperDiff::Test::Person {|
              plain_line %|    name: "a",|
              # plain_line %|    age: 9,|  # FIXME
              plain_line %|    age: 9|
              # alpha_line %|-   foo: "bar",|  # FIXME
              alpha_line %|-   foo: "bar"|
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
      it "produces the correct output when used in the positive" do
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
                beta %|#<SuperDiff::Test::ShippingAddress line_1: "456 Ponderosa Ct.", line_2: nil, city: "Hill Valley", state: "CA", zip: "90382">|
              end

              line do
                plain "to have attributes "
                alpha %|(line_1: "123 Main St.", city: "Oakland", state: "CA", zip: "91234")|
              end
            },
            diff: proc {
              plain_line %|  #<SuperDiff::Test::ShippingAddress {|
              alpha_line %|-   line_1: "123 Main St.",|
              beta_line %|+   line_1: "456 Ponderosa Ct.",|
              plain_line %|    line_2: nil,|
              alpha_line %|-   city: "Oakland",|
              beta_line %|+   city: "Hill Valley",|
              plain_line %|    state: "CA",|
              # alpha_line %|-   zip: "91234",|  # FIXME
              alpha_line %|-   zip: "91234"|
              beta_line %|+   zip: "90382"|
              plain_line %|  }>|
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end

      it "produces the correct output when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = {
              line_1: "123 Main St.",
              city: "Oakland",
              state: "CA",
              zip: "91234"
            }
            actual = SuperDiff::Test::ShippingAddress.new(
              line_1: "123 Main St.",
              line_2: nil,
              city: "Oakland",
              state: "CA",
              zip: "91234"
            )
            expect(actual).not_to have_attributes(expected)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(actual).not_to have_attributes(expected)|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "              Expected "
                beta %|#<SuperDiff::Test::ShippingAddress line_1: "123 Main St.", line_2: nil, city: "Oakland", state: "CA", zip: "91234">|
              end

              line do
                plain "not to have attributes "
                alpha %|(line_1: "123 Main St.", city: "Oakland", state: "CA", zip: "91234")|
              end
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
                beta %|#<SuperDiff::Test::ShippingAddress line_1: "456 Ponderosa Ct.", line_2: nil, city: "Hill Valley", state: "CA", zip: "90382">|
              end

              line do
                plain "to respond to "
                alpha %|:foo|
                plain " and "
                alpha %|:baz|
                plain " with "
                alpha %|0|
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
              # alpha_line %|-   foo: "bar",|  # FIXME
              alpha_line %|-   foo: "bar"|
              alpha_line %|-   baz: "qux"|
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
