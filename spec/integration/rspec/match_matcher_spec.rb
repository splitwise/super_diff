require "spec_helper"

RSpec.describe "Integration with RSpec's #match matcher", type: :integration do
  context "when the expected value is a hash-including-<something>" do
    context "that is small" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = a_hash_including(city: "Hill Valley")
            actual   = { city: "Burbank" }
            expect(actual).to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|{ city: "Burbank" }|
                    plain " to match "
                    expected %|#<a hash including (city: "Hill Valley")>|
                    plain "."
                  end
                end,
              diff:
                proc do
                  plain_line "  {"
                  expected_line %|-   city: "Hill Valley"|
                  actual_line %|+   city: "Burbank"|
                  plain_line "  }"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = a_hash_including(city: "Burbank")
            actual   = { city: "Burbank" }
            expect(actual).not_to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).not_to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|{ city: "Burbank" }|
                    plain " not to match "
                    expected %|#<a hash including (city: "Burbank")>|
                    plain "."
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end

    context "that is large" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = a_hash_including(
              city: "Hill Valley",
              zip: "90382"
            )
            actual   = {
              line_1: "123 Main St.",
              city: "Burbank",
              state: "CA",
              zip: "90210"
            }
            expect(actual).to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|{ line_1: "123 Main St.", city: "Burbank", state: "CA", zip: "90210" }|
                  end

                  line do
                    plain "to match "
                    expected %|#<a hash including (city: "Hill Valley", zip: "90382")>|
                  end
                end,
              diff:
                proc do
                  plain_line "  {"
                  plain_line %|    line_1: "123 Main St.",|
                  expected_line %|-   city: "Hill Valley",|
                  actual_line %|+   city: "Burbank",|
                  plain_line %|    state: "CA",|
                  expected_line %|-   zip: "90382"|
                  actual_line %|+   zip: "90210"|
                  plain_line "  }"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = a_hash_including(
              city: "Burbank",
              zip: "90210"
            )
            actual   = {
              line_1: "123 Main St.",
              city: "Burbank",
              state: "CA",
              zip: "90210"
            }
            expect(actual).not_to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).not_to match(expected)",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "    Expected "
                    actual %|{ line_1: "123 Main St.", city: "Burbank", state: "CA", zip: "90210" }|
                  end

                  line do
                    plain "not to match "
                    expected %|#<a hash including (city: "Burbank", zip: "90210")>|
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end
  end

  context "when the expected value includes a hash-including-<something>" do
    context "and the corresponding actual   value is a hash" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = {
              name: "Marty McFly",
              address: a_hash_including(
                city: "Hill Valley",
                zip: "90382"
              )
            }
            actual   = {
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
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|{ name: "Marty McFly", address: { line_1: "123 Main St.", city: "Burbank", state: "CA", zip: "90210" } }|
                  end

                  line do
                    plain "to match "
                    expected %|{ name: "Marty McFly", address: #<a hash including (city: "Hill Valley", zip: "90382")> }|
                  end
                end,
              diff:
                proc do
                  plain_line "  {"
                  plain_line %|    name: "Marty McFly",|
                  plain_line "    address: {"
                  plain_line %|      line_1: "123 Main St.",|
                  expected_line %|-     city: "Hill Valley",|
                  actual_line %|+     city: "Burbank",|
                  plain_line %|      state: "CA",|
                  expected_line %|-     zip: "90382"|
                  actual_line %|+     zip: "90210"|
                  plain_line "    }"
                  plain_line "  }"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = {
              name: "Marty McFly",
              address: a_hash_including(
                city: "Burbank",
                zip: "90210"
              )
            }
            actual   = {
              name: "Marty McFly",
              address: {
                line_1: "123 Main St.",
                city: "Burbank",
                state: "CA",
                zip: "90210"
              }
            }
            expect(actual).not_to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).not_to match(expected)",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "    Expected "
                    actual %|{ name: "Marty McFly", address: { line_1: "123 Main St.", city: "Burbank", state: "CA", zip: "90210" } }|
                  end

                  line do
                    plain "not to match "
                    expected %|{ name: "Marty McFly", address: #<a hash including (city: "Burbank", zip: "90210")> }|
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end

    context "and the corresponding actual   value is not a hash" do
      it "produces the correct failure message" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = {
              name: "Marty McFly",
              address: a_hash_including(
                city: "Hill Valley",
                zip: "90382"
              )
            }
            actual   = {
              name: "Marty McFly",
              address: nil
            }
            expect(actual).to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|{ name: "Marty McFly", address: nil }|
                  end

                  line do
                    plain "to match "
                    expected %|{ name: "Marty McFly", address: #<a hash including (city: "Hill Valley", zip: "90382")> }|
                  end
                end,
              diff:
                proc do
                  plain_line "  {"
                  plain_line %!    name: "Marty McFly",!
                  expected_line "-   address: #<a hash including ("
                  expected_line %!-     city: "Hill Valley",!
                  expected_line %!-     zip: "90382"!
                  expected_line "-   )>"
                  actual_line "+   address: nil"
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

  # HINT: `a_hash_including` is an alias of `include` in the rspec-expectations gem.
  #       `hash_including` is an argument matcher in the rspec-mocks gem.
  context "when the expected value is `hash-including-<something>`, not `a-hash-including-<something>`" do
    it "produces the correct failure message" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = hash_including(city: "Hill Valley")
          actual   = { city: "Burbank" }
          expect(actual).to match(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to match(expected)",
            expectation:
              proc do
                line do
                  plain "Expected "
                  actual %|{ city: "Burbank" }|
                  plain " to match "
                  expected %|#<a hash including (city: "Hill Valley")>|
                  plain "."
                end
              end,
            diff:
              proc do
                plain_line "  {"
                expected_line %|-   city: "Hill Valley"|
                actual_line %|+   city: "Burbank"|
                plain_line "  }"
              end
          )

        expect(program).to produce_output_when_run(expected_output).in_color(
          color_enabled
        )
      end
    end
  end

  context "when the expected value is a collection-including-<something>" do
    context "that is small" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = a_collection_including("a")
            actual   = ["b"]
            expect(actual).to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|["b"]|
                    plain " to match "
                    expected %|#<a collection including ("a")>|
                    plain "."
                  end
                end,
              diff:
                proc do
                  plain_line "  ["
                  plain_line %|    "b"|
                  # expected_line %|-   "a",|   # FIXME
                  expected_line %|-   "a"|
                  plain_line "  ]"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = a_collection_including("b")
            actual   = ["b"]
            expect(actual).not_to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).not_to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|["b"]|
                    plain " not to match "
                    expected %|#<a collection including ("b")>|
                    plain "."
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end

    context "that is large" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = a_collection_including("milk", "bread")
            actual   = ["milk", "toast", "eggs", "cheese", "English muffins"]
            expect(actual).to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|["milk", "toast", "eggs", "cheese", "English muffins"]|
                  end

                  line do
                    plain "to match "
                    expected %|#<a collection including ("milk", "bread")>|
                  end
                end,
              diff:
                proc do
                  plain_line "  ["
                  plain_line %|    "milk",|
                  plain_line %|    "toast",|
                  plain_line %|    "eggs",|
                  plain_line %|    "cheese",|
                  # plain_line    %|    "English muffins",|  # FIXME
                  plain_line %|    "English muffins"|
                  expected_line %|-   "bread"|
                  plain_line "  ]"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = a_collection_including("milk", "toast")
            actual   = ["milk", "toast", "eggs", "cheese", "English muffins"]
            expect(actual).not_to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).not_to match(expected)",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "    Expected "
                    actual %|["milk", "toast", "eggs", "cheese", "English muffins"]|
                  end

                  line do
                    plain "not to match "
                    expected %|#<a collection including ("milk", "toast")>|
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end
  end

  context "when the expected value includes a collection-including-<something>" do
    context "and the corresponding actual   value is an array" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = {
              name: "shopping list",
              contents: a_collection_including("milk", "bread")
            }
            actual   = {
              name: "shopping list",
              contents: ["milk", "toast", "eggs"]
            }
            expect(actual).to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|{ name: "shopping list", contents: ["milk", "toast", "eggs"] }|
                  end

                  line do
                    plain "to match "
                    expected %|{ name: "shopping list", contents: #<a collection including ("milk", "bread")> }|
                  end
                end,
              diff:
                proc do
                  plain_line "  {"
                  plain_line %|    name: "shopping list",|
                  plain_line "    contents: ["
                  plain_line %|      "milk",|
                  plain_line %|      "toast",|
                  # plain_line    %|      "eggs",|     # FIXME
                  plain_line %|      "eggs"|
                  expected_line %|-     "bread"|
                  plain_line "    ]"
                  plain_line "  }"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = {
              name: "shopping list",
              contents: a_collection_including("milk", "toast")
            }
            actual   = {
              name: "shopping list",
              contents: ["milk", "toast", "eggs"]
            }
            expect(actual).not_to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).not_to match(expected)",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "    Expected "
                    actual %|{ name: "shopping list", contents: ["milk", "toast", "eggs"] }|
                  end

                  line do
                    plain "not to match "
                    expected %|{ name: "shopping list", contents: #<a collection including ("milk", "toast")> }|
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end

    context "when the corresponding actual   value is not an array" do
      it "produces the correct failure message" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = {
              name: "shopping list",
              contents: a_collection_including("milk", "bread")
            }
            actual   = {
              name: "shopping list",
              contents: nil
            }
            expect(actual).to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|{ name: "shopping list", contents: nil }|
                  end

                  line do
                    plain "to match "
                    expected %|{ name: "shopping list", contents: #<a collection including ("milk", "bread")> }|
                  end
                end,
              diff:
                proc do
                  plain_line "  {"
                  plain_line %!    name: "shopping list",!
                  expected_line "-   contents: #<a collection including ("
                  expected_line %!-     "milk",!
                  expected_line %!-     "bread"!
                  expected_line "-   )>"
                  actual_line "+   contents: nil"
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

  context "when the expected value is an array-including-<something>" do
    it "produces the correct failure message" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = array_including("a")
          actual   = ["b"]
          expect(actual).to match(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to match(expected)",
            expectation:
              proc do
                line do
                  plain "Expected "
                  actual %|["b"]|
                  plain " to match "
                  expected %|#<a collection including ("a")>|
                  plain "."
                end
              end,
            diff:
              proc do
                plain_line "  ["
                plain_line %|    "b"|
                # expected_line %|-   "a",|   # FIXME
                expected_line %|-   "a"|
                plain_line "  ]"
              end
          )

        expect(program).to produce_output_when_run(expected_output).in_color(
          color_enabled
        )
      end
    end
  end

  context "when the expected value is an object-having-attributes" do
    context "that is small" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = an_object_having_attributes(name: "b")
            actual   = A.new("a")
            expect(actual).to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|#<A name: "a">|
                    plain " to match "
                    expected %|#<an object having attributes (name: "b")>|
                    plain "."
                  end
                end,
              diff:
                proc do
                  plain_line "  #<A {"
                  # expected_line %|-   name: "b",|  # FIXME
                  expected_line %|-   name: "b"|
                  actual_line %|+   name: "a"|
                  plain_line "  }>"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = an_object_having_attributes(name: "b")
            actual   = A.new("b")
            expect(actual).not_to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).not_to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|#<A name: "b">|
                    plain " not to match "
                    expected %|#<an object having attributes (name: "b")>|
                    plain "."
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end

    context "that is large" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = an_object_having_attributes(
              line_1: "123 Main St.",
              city: "Oakland",
              zip: "91234",
              state: "CA",
              something_else: "blah"
            )
            actual   = SuperDiff::Test::ShippingAddress.new(
              line_1: "456 Ponderosa Ct.",
              line_2: nil,
              city: "Hill Valley",
              state: "CA",
              zip: "90382"
            )
            expect(actual).to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|#<SuperDiff::Test::ShippingAddress line_1: "456 Ponderosa Ct.", line_2: nil, city: "Hill Valley", state: "CA", zip: "90382">|
                  end

                  line do
                    plain "to match "
                    expected %|#<an object having attributes (line_1: "123 Main St.", city: "Oakland", zip: "91234", state: "CA", something_else: "blah")>|
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
                  # expected_line %|-   zip: "91234",|  # FIXME
                  # actual_line   %|+   zip: "90382",|  # FIXME
                  expected_line %|-   zip: "91234"|
                  actual_line %|+   zip: "90382"|
                  # expected_line %|-   something_else: "blah"|  # TODO
                  expected_line %|-   something_else: "blah",|
                  plain_line "  }>"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = an_object_having_attributes(
              line_1: "123 Main St.",
              city: "Oakland",
              zip: "91234"
            )
            actual   = SuperDiff::Test::ShippingAddress.new(
              line_1: "123 Main St.",
              line_2: nil,
              city: "Oakland",
              zip: "91234",
              state: "CA"
            )
            expect(actual).not_to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).not_to match(expected)",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "    Expected "
                    actual %|#<SuperDiff::Test::ShippingAddress line_1: "123 Main St.", line_2: nil, city: "Oakland", state: "CA", zip: "91234">|
                  end

                  line do
                    plain "not to match "
                    expected %|#<an object having attributes (line_1: "123 Main St.", city: "Oakland", zip: "91234")>|
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end
  end

  context "when the expected value includes an object-having-attributes" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
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
          actual   = {
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
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to match(expected)",
            expectation:
              proc do
                line do
                  plain "Expected "
                  actual %|{ name: "Marty McFly", shipping_address: #<SuperDiff::Test::ShippingAddress line_1: "456 Ponderosa Ct.", line_2: nil, city: "Hill Valley", state: "CA", zip: "90382"> }|
                end

                line do
                  plain "to match "
                  expected %|{ name: "Marty McFly", shipping_address: #<an object having attributes (line_1: "123 Main St.", city: "Oakland", state: "CA", zip: "91234", something_else: "blah")> }|
                end
              end,
            diff:
              proc do
                plain_line "  {"
                plain_line %|    name: "Marty McFly",|
                plain_line "    shipping_address: #<SuperDiff::Test::ShippingAddress {"
                expected_line %|-     line_1: "123 Main St.",|
                actual_line %|+     line_1: "456 Ponderosa Ct.",|
                plain_line "      line_2: nil,"
                expected_line %|-     city: "Oakland",|
                actual_line %|+     city: "Hill Valley",|
                plain_line %|      state: "CA",|
                # expected_line %|-     zip: "91234",|  # FIXME
                expected_line %|-     zip: "91234"|
                actual_line %|+     zip: "90382"|
                # expected_line %|-     something_else: "blah"|  # TODO
                expected_line %|-     something_else: "blah",|
                plain_line "    }>"
                plain_line "  }"
              end
          )

        expect(program).to produce_output_when_run(expected_output).in_color(
          color_enabled
        )
      end
    end

    it "produces the correct failure message when used the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = {
            name: "Marty McFly",
            shipping_address: an_object_having_attributes(
              line_1: "123 Main St.",
              city: "Oakland",
              state: "CA",
              zip: "91234"
            )
          }
          actual   = {
            name: "Marty McFly",
            shipping_address: SuperDiff::Test::ShippingAddress.new(
              line_1: "123 Main St.",
              line_2: nil,
              city: "Oakland",
              state: "CA",
              zip: "91234",
            )
          }
          expect(actual).not_to match(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).not_to match(expected)",
            newline_before_expectation: true,
            expectation:
              proc do
                line do
                  plain "    Expected "
                  actual %|{ name: "Marty McFly", shipping_address: #<SuperDiff::Test::ShippingAddress line_1: "123 Main St.", line_2: nil, city: "Oakland", state: "CA", zip: "91234"> }|
                end

                line do
                  plain "not to match "
                  expected %|{ name: "Marty McFly", shipping_address: #<an object having attributes (line_1: "123 Main St.", city: "Oakland", state: "CA", zip: "91234")> }|
                end
              end
          )

        expect(program).to produce_output_when_run(expected_output).in_color(
          color_enabled
        )
      end
    end
  end

  context "when the expected value is a collection-containing-exactly-<something>" do
    context "that is small" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = a_collection_containing_exactly("a")
            actual   = ["b"]
            expect(actual).to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|["b"]|
                    plain " to match "
                    expected %|#<a collection containing exactly ("a")>|
                    plain "."
                  end
                end,
              diff:
                proc do
                  plain_line "  ["
                  actual_line %|+   "b",|
                  # expected_line %|-   "a"|  # TODO
                  expected_line %|-   "a",|
                  plain_line "  ]"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = a_collection_containing_exactly("b")
            actual   = ["b"]
            expect(actual).not_to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).not_to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|["b"]|
                    plain " not to match "
                    expected %|#<a collection containing exactly ("b")>|
                    plain "."
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end

    context "that is large" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = a_collection_containing_exactly("milk", "bread")
            actual   = ["milk", "toast", "eggs", "cheese", "English muffins"]
            expect(actual).to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|["milk", "toast", "eggs", "cheese", "English muffins"]|
                  end

                  line do
                    plain "to match "
                    expected %|#<a collection containing exactly ("milk", "bread")>|
                  end
                end,
              diff:
                proc do
                  plain_line "  ["
                  plain_line %|    "milk",|
                  actual_line %|+   "toast",|
                  actual_line %|+   "eggs",|
                  actual_line %|+   "cheese",|
                  actual_line %|+   "English muffins",|
                  # expected_line %|-   "bread"|  # TODO
                  expected_line %|-   "bread",|
                  plain_line "  ]"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = a_collection_containing_exactly("milk", "eggs", "toast")
            actual   = ["milk", "toast", "eggs"]
            expect(actual).not_to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).not_to match(expected)",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "    Expected "
                    actual %|["milk", "toast", "eggs"]|
                  end

                  line do
                    plain "not to match "
                    expected %|#<a collection containing exactly ("milk", "eggs", "toast")>|
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end
  end

  context "when the expected value includes a collection-containing-exactly-<something>" do
    context "and the corresponding actual   value is an array" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = {
              name: "shopping list",
              contents: a_collection_containing_exactly("milk", "bread")
            }
            actual   = {
              name: "shopping list",
              contents: ["milk", "toast", "eggs"]
            }
            expect(actual).to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|{ name: "shopping list", contents: ["milk", "toast", "eggs"] }|
                  end

                  line do
                    plain "to match "
                    expected %|{ name: "shopping list", contents: #<a collection containing exactly ("milk", "bread")> }|
                  end
                end,
              diff:
                proc do
                  plain_line "  {"
                  plain_line %|    name: "shopping list",|
                  plain_line "    contents: ["
                  plain_line %|      "milk",|
                  actual_line %|+     "toast",|
                  actual_line %|+     "eggs",|
                  # expected_line %|-     "bread"|  # TODO
                  expected_line %|-     "bread",|
                  plain_line "    ]"
                  plain_line "  }"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = {
              name: "shopping list",
              contents: a_collection_containing_exactly("milk", "eggs", "toast")
            }
            actual   = {
              name: "shopping list",
              contents: ["milk", "toast", "eggs"]
            }
            expect(actual).not_to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).not_to match(expected)",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "    Expected "
                    actual %|{ name: "shopping list", contents: ["milk", "toast", "eggs"] }|
                  end

                  line do
                    plain "not to match "
                    expected %|{ name: "shopping list", contents: #<a collection containing exactly ("milk", "eggs", "toast")> }|
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end

    context "when the corresponding actual   value is not an array" do
      it "produces the correct failure message" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = {
              name: "shopping list",
              contents: a_collection_containing_exactly("milk", "bread")
            }
            actual   = {
              name: "shopping list",
              contents: nil
            }
            expect(actual).to match(expected)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(actual).to match(expected)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual %|{ name: "shopping list", contents: nil }|
                  end

                  line do
                    plain "to match "
                    expected %|{ name: "shopping list", contents: #<a collection containing exactly ("milk", "bread")> }|
                  end
                end,
              diff:
                proc do
                  plain_line "  {"
                  plain_line %!    name: "shopping list",!
                  expected_line "-   contents: #<a collection containing exactly ("
                  expected_line %!-     "milk",!
                  expected_line %!-     "bread"!
                  expected_line "-   )>"
                  actual_line "+   contents: nil"
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
