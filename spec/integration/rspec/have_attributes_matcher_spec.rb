require "spec_helper"

RSpec.describe "Integration with RSpec's #have_attributes matcher",
               type: :integration do
  context "when the actual   value is an object" do
    context "with a small set of attributes" do
      context "when all of the names are methods on the actual   object" do
        it "produces the correct output when used in the positive" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expected = { name: "b" }
              actual   = SuperDiff::Test::Person.new(name: "a", age: 9)
              expect(actual).to have_attributes(expected)
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(actual).to have_attributes(expected)",
                expectation:
                  proc do
                    line do
                      plain "Expected "
                      actual %|#<SuperDiff::Test::Person name: "a", age: 9>|
                      plain " to have attributes "
                      expected %|(name: "b")|
                      plain "."
                    end
                  end,
                diff:
                  proc do
                    plain_line "  #<SuperDiff::Test::Person {"
                    # expected_line %|-   name: "b",|  # FIXME
                    expected_line %|-   name: "b"|
                    actual_line %|+   name: "a",|
                    plain_line "    age: 9"
                    plain_line "  }>"
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled)
          end
        end

        it "produces the correct output when used in the negative" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expected = { name: "a" }
              actual   = SuperDiff::Test::Person.new(name: "a", age: 9)
              expect(actual).not_to have_attributes(expected)
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(actual).not_to have_attributes(expected)",
                expectation:
                  proc do
                    line do
                      plain "Expected "
                      actual %|#<SuperDiff::Test::Person name: "a", age: 9>|
                      plain " not to have attributes "
                      expected %|(name: "a")|
                      plain "."
                    end
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled)
          end
        end
      end

      context "when some of the names are not methods on the actual   object" do
        it "produces the correct output" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expected = { name: "b", foo: "bar" }
              actual   = SuperDiff::Test::Person.new(name: "a", age: 9)
              expect(actual).to have_attributes(expected)
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(actual).to have_attributes(expected)",
                expectation:
                  proc do
                    line do
                      plain "Expected "
                      actual %|#<SuperDiff::Test::Person name: "a", age: 9>|
                      plain " to respond to "
                      expected ":foo"
                      plain " with "
                      expected "0"
                      plain " arguments."
                    end
                  end,
                diff:
                  proc do
                    plain_line "  #<SuperDiff::Test::Person {"
                    plain_line %|    name: "a",|
                    # plain_line    %|    age: 9,|  # FIXME
                    plain_line "    age: 9"
                    # expected_line %|-   foo: "bar"|  # FIXME
                    expected_line %|-   foo: "bar",|
                    plain_line "  }>"
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled)
          end
        end
      end
    end

    context "with a large set of attributes" do
      context "when all of the names are methods on the actual   object" do
        it "produces the correct output when used in the positive" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expected = {
                line_1: "123 Main St.",
                city: "Oakland",
                state: "CA",
                zip: "91234"
              }
              actual   = SuperDiff::Test::ShippingAddress.new(
                line_1: "456 Ponderosa Ct.",
                line_2: nil,
                city: "Hill Valley",
                state: "CA",
                zip: "90382"
              )
              expect(actual).to have_attributes(expected)
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(actual).to have_attributes(expected)",
                expectation:
                  proc do
                    line do
                      plain "          Expected "
                      actual %|#<SuperDiff::Test::ShippingAddress line_1: "456 Ponderosa Ct.", line_2: nil, city: "Hill Valley", state: "CA", zip: "90382">|
                    end

                    line do
                      plain "to have attributes "
                      expected %|(line_1: "123 Main St.", city: "Oakland", state: "CA", zip: "91234")|
                    end
                  end,
                diff:
                  proc do
                    plain_line "  #<SuperDiff::Test::ShippingAddress {"
                    expected_line %|-   line_1: "123 Main St.",|
                    actual_line %|+   line_1: "456 Ponderosa Ct.",|
                    plain_line "    line_2: nil,"
                    expected_line %|-   city: "Oakland",|
                    actual_line %|+   city: "Hill Valley",|
                    plain_line %|    state: "CA",|
                    expected_line %|-   zip: "91234",| # FIXME
                    actual_line %|+   zip: "90382"|
                    plain_line "  }>"
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled)
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
              actual   = SuperDiff::Test::ShippingAddress.new(
                line_1: "123 Main St.",
                line_2: nil,
                city: "Oakland",
                state: "CA",
                zip: "91234"
              )
              expect(actual).not_to have_attributes(expected)
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(actual).not_to have_attributes(expected)",
                newline_before_expectation: true,
                expectation:
                  proc do
                    line do
                      plain "              Expected "
                      actual %|#<SuperDiff::Test::ShippingAddress line_1: "123 Main St.", line_2: nil, city: "Oakland", state: "CA", zip: "91234">|
                    end

                    line do
                      plain "not to have attributes "
                      expected %|(line_1: "123 Main St.", city: "Oakland", state: "CA", zip: "91234")|
                    end
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled)
          end
        end
      end

      context "when some of the names are not methods on the actual   object" do
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
              actual   = SuperDiff::Test::ShippingAddress.new(
                line_1: "456 Ponderosa Ct.",
                line_2: nil,
                city: "Hill Valley",
                state: "CA",
                zip: "90382"
              )
              expect(actual).to have_attributes(expected)
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(actual).to have_attributes(expected)",
                expectation:
                  proc do
                    line do
                      plain "     Expected "
                      actual %|#<SuperDiff::Test::ShippingAddress line_1: "456 Ponderosa Ct.", line_2: nil, city: "Hill Valley", state: "CA", zip: "90382">|
                    end

                    line do
                      plain "to respond to "
                      expected ":foo"
                      plain " and "
                      expected ":baz"
                      plain " with "
                      expected "0"
                      plain " arguments"
                    end
                  end,
                diff:
                  proc do
                    plain_line "  #<SuperDiff::Test::ShippingAddress {"
                    plain_line %|    line_1: "456 Ponderosa Ct.",|
                    plain_line "    line_2: nil,"
                    plain_line %|    city: "Hill Valley",|
                    plain_line %|    state: "CA",|
                    # plain_line    %|    zip: "90382",|  # FIXME
                    plain_line %|    zip: "90382"|
                    expected_line %|-   foo: "bar",|
                    # expected_line %|-   baz: "qux"|  # TODO
                    expected_line %|-   baz: "qux",|
                    plain_line "  }>"
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled)
          end
        end
      end
    end
  end

  context "when the actual   value is actually a hash instead of an object" do
    it "displays the diff as if we were comparing hashes" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = { name: "Elliot", age: 32 }
          actual   = {}
          expect(actual).to have_attributes(expected)
        TEST

        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to have_attributes(expected)",
            expectation:
              proc do
                line do
                  plain "Expected "
                  actual "{}"
                  plain " to respond to "
                  expected ":name"
                  plain " and "
                  expected ":age"
                  plain " with "
                  expected "0"
                  plain " arguments."
                end
              end,
            diff:
              proc do
                plain_line "  {"
                expected_line %|-   name: "Elliot",|
                expected_line "-   age: 32"
                plain_line "  }"
              end
          )

        expect(program).to produce_output_when_run(expected_output).in_color(
          color_enabled
        )
      end
    end

    # TODO: Add as many fuzzy matchers as we can here
    context "that contains fuzzy matcher objects instead of an object" do
      it "displays the hash correctly" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = {
              name: "Elliot",
              shipping_address: an_object_having_attributes(
                line_1: a_kind_of(String),
                line_2: nil,
                city: an_instance_of(String),
                state: "CA",
                zip: "91234"
              ),
              order_ids: a_collection_including(1, 2),
              data: a_hash_including(active: true),
              created_at: a_value_within(1).of(Time.utc(2020, 4, 9))
            }

            actual   = {}

            expect(actual).to have_attributes(expected)
          TEST

          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).to have_attributes(expected)",
              expectation:
                proc do
                  line do
                    plain "     Expected "
                    actual "{}"
                  end

                  line do
                    plain "to respond to "
                    expected ":name"
                    plain ", "
                    expected ":shipping_address"
                    plain ", "
                    expected ":order_ids"
                    plain ", "
                    expected ":data"
                    plain " and "
                    expected ":created_at"
                    plain " with "
                    expected "0"
                    plain " arguments"
                  end
                end,
              diff:
                proc do
                  plain_line "  {"
                  expected_line %|-   name: "Elliot",|
                  expected_line "-   shipping_address: #<an object having attributes ("
                  expected_line "-     line_1: #<a kind of String>,"
                  expected_line "-     line_2: nil,"
                  expected_line "-     city: #<an instance of String>,"
                  expected_line %|-     state: "CA",|
                  expected_line %|-     zip: "91234"|
                  expected_line "-   )>,"
                  expected_line "-   order_ids: #<a collection including ("
                  expected_line "-     1,"
                  expected_line "-     2"
                  expected_line "-   )>,"
                  expected_line "-   data: #<a hash including ("
                  expected_line "-     active: true"
                  expected_line "-   )>,"
                  expected_line "-   created_at: #<a value within 1 of #<Time {"
                  expected_line "-     year: 2020,"
                  expected_line "-     month: 4,"
                  expected_line "-     day: 9,"
                  expected_line "-     hour: 0,"
                  expected_line "-     min: 0,"
                  expected_line "-     sec: 0,"
                  expected_line "-     subsec: 0,"
                  expected_line %|-     zone: "UTC",|
                  expected_line "-     utc_offset: 0"
                  expected_line "-   }>>"
                  plain_line "  }"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end
  end
end
