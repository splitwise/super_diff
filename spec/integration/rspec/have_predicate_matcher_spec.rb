require "spec_helper"

RSpec.describe "Integration with RSpec's #have_<predicate> matcher",
               type: :integration do
  context "when the predicate method doesn't exist on the object" do
    context "when the predicate method doesn't exist on the object" do
      it "produces the correct failure message" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = "expect(:words).to have_power"
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: snippet,
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual ":words"
                    plain " to respond to "
                    expected "has_power?"
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

    context "when the inspected version of the actual   value is long" do
      it "produces the correct failure message" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            hash = { a: "lot", of: "keys", and: "things", like: "that", lets: "add", more: "keys" }
            expect(hash).to have_mapping
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(hash).to have_mapping",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "     Expected "
                    actual %|{ a: "lot", of: "keys", and: "things", like: "that", lets: "add", more: "keys" }|
                  end

                  line do
                    plain "to respond to "
                    expected "has_mapping?"
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

  context "when the predicate method exists on the object" do
    context "but is private" do
      context "when the inspected version of the actual   value is short" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              class Robot
                private def has_arms?; end
              end

              expect(Robot.new).to have_arms
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(Robot.new).to have_arms",
                expectation:
                  proc do
                    line do
                      plain "Expected "
                      actual "#<Robot>"
                      plain " to have a public method "
                      expected "has_arms?"
                      plain "."
                    end
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled).removing_object_ids
          end
        end
      end

      context "when the inspected version of the actual   value is long" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              hash = { a: "lot", of: "keys", and: "things", like: "that", lets: "add", more: "keys" }

              class << hash
                private def has_mapping?; end
              end

              expect(hash).to have_mapping
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(hash).to have_mapping",
                newline_before_expectation: true,
                expectation:
                  proc do
                    line do
                      plain "               Expected "
                      actual %|{ a: "lot", of: "keys", and: "things", like: "that", lets: "add", more: "keys" }|
                    end

                    line do
                      plain "to have a public method "
                      expected "has_mapping?"
                    end
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled).removing_object_ids
          end
        end
      end
    end

    context "and is public" do
      context "and returns false" do
        context "and takes arguments" do
          context "when the inspected version of the actual   value is short" do
            it "produces the correct failure message" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  class Drink
                    def has_ingredients?(*); false; end
                  end

                  expect(Drink.new).to have_ingredients(:vodka)
                TEST
                program =
                  make_plain_test_program(snippet, color_enabled: color_enabled)

                expected_output =
                  build_expected_output(
                    color_enabled: color_enabled,
                    snippet: "expect(Drink.new).to have_ingredients(:vodka)",
                    expectation:
                      proc do
                        line do
                          plain "Expected "
                          actual "#<Drink>"
                          plain " to return a truthy result for "
                          expected "has_ingredients?(:vodka)"
                          plain "."
                        end
                      end
                  )

                expect(program).to produce_output_when_run(
                  expected_output
                ).in_color(color_enabled).removing_object_ids
              end
            end
          end

          context "when the inspected version of the actual   value is long" do
            it "produces the correct failure message" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  hash = { a: "lot", of: "keys", and: "things", like: "that", lets: "add", more: "keys" }

                  class << hash
                    def has_contents?(*args); false; end
                  end

                  expect(hash).to have_contents("keys", "upon", "keys")
                TEST
                program =
                  make_plain_test_program(snippet, color_enabled: color_enabled)

                expected_output =
                  build_expected_output(
                    color_enabled: color_enabled,
                    snippet:
                      %|expect(hash).to have_contents("keys", "upon", "keys")|,
                    newline_before_expectation: true,
                    expectation:
                      proc do
                        line do
                          plain "                     Expected "
                          actual %|{ a: "lot", of: "keys", and: "things", like: "that", lets: "add", more: "keys" }|
                        end

                        line do
                          plain "to return a truthy result for "
                          expected %|has_contents?("keys", "upon", "keys")|
                        end
                      end
                  )

                expect(program).to produce_output_when_run(
                  expected_output
                ).in_color(color_enabled).removing_object_ids
              end
            end
          end
        end

        context "and takes no arguments" do
          context "when the inspected version of the actual   value is short" do
            it "produces the correct failure message" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  class Robot
                    def has_arms?; false; end
                  end

                  expect(Robot.new).to have_arms
                TEST
                program =
                  make_plain_test_program(snippet, color_enabled: color_enabled)

                expected_output =
                  build_expected_output(
                    color_enabled: color_enabled,
                    snippet: "expect(Robot.new).to have_arms",
                    expectation:
                      proc do
                        line do
                          plain "Expected "
                          actual "#<Robot>"
                          plain " to return a truthy result for "
                          expected "has_arms?"
                          plain "."
                        end
                      end
                  )

                expect(program).to produce_output_when_run(
                  expected_output
                ).in_color(color_enabled).removing_object_ids
              end
            end
          end

          context "when the inspected version of the actual   value is long" do
            it "produces the correct failure message" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  hash = { a: "lot", of: "keys", and: "things", like: "that", lets: "add", more: "keys" }

                  class << hash
                    def has_mapping?; false; end
                  end

                  expect(hash).to have_mapping
                TEST
                program =
                  make_plain_test_program(snippet, color_enabled: color_enabled)

                expected_output =
                  build_expected_output(
                    color_enabled: color_enabled,
                    snippet: "expect(hash).to have_mapping",
                    newline_before_expectation: true,
                    expectation:
                      proc do
                        line do
                          plain "                     Expected "
                          actual %|{ a: "lot", of: "keys", and: "things", like: "that", lets: "add", more: "keys" }|
                        end

                        line do
                          plain "to return a truthy result for "
                          expected "has_mapping?"
                        end
                      end
                  )

                expect(program).to produce_output_when_run(
                  expected_output
                ).in_color(color_enabled).removing_object_ids
              end
            end
          end
        end
      end

      context "and returns true" do
        context "and takes arguments" do
          context "when the inspected version of the actual   value is short" do
            it "produces the correct failure message" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  class Drink
                    def has_ingredients?(*); true; end
                  end

                  expect(Drink.new).not_to have_ingredients(:vodka)
                TEST
                program =
                  make_plain_test_program(snippet, color_enabled: color_enabled)

                expected_output =
                  build_expected_output(
                    color_enabled: color_enabled,
                    snippet:
                      "expect(Drink.new).not_to have_ingredients(:vodka)",
                    expectation:
                      proc do
                        line do
                          plain "Expected "
                          actual "#<Drink>"
                          plain " not to return a truthy result for "
                          expected "has_ingredients?(:vodka)"
                          plain "."
                        end
                      end
                  )

                expect(program).to produce_output_when_run(
                  expected_output
                ).in_color(color_enabled).removing_object_ids
              end
            end
          end

          context "when the inspected version of the actual   value is long" do
            it "produces the correct failure message" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  hash = { a: "lot", of: "keys", and: "things", like: "that", lets: "add", more: "keys" }

                  class << hash
                    def has_contents?(*args); true; end
                  end

                  expect(hash).not_to have_contents("keys", "upon", "keys")
                TEST
                program =
                  make_plain_test_program(snippet, color_enabled: color_enabled)

                expected_output =
                  build_expected_output(
                    color_enabled: color_enabled,
                    snippet:
                      %|expect(hash).not_to have_contents("keys", "upon", "keys")|,
                    newline_before_expectation: true,
                    expectation:
                      proc do
                        line do
                          plain "                         Expected "
                          actual %|{ a: "lot", of: "keys", and: "things", like: "that", lets: "add", more: "keys" }|
                        end

                        line do
                          plain "not to return a truthy result for "
                          expected %|has_contents?("keys", "upon", "keys")|
                        end
                      end
                  )

                expect(program).to produce_output_when_run(
                  expected_output
                ).in_color(color_enabled).removing_object_ids
              end
            end
          end
        end

        context "and takes no arguments" do
          context "when the inspected version of the actual   value is short" do
            it "produces the correct failure message when used in the negative" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  class Robot
                    def has_arms?; true; end
                  end

                  expect(Robot.new).not_to have_arms
                TEST
                program =
                  make_plain_test_program(snippet, color_enabled: color_enabled)

                expected_output =
                  build_expected_output(
                    color_enabled: color_enabled,
                    snippet: "expect(Robot.new).not_to have_arms",
                    expectation:
                      proc do
                        line do
                          plain "Expected "
                          actual "#<Robot>"
                          plain " not to return a truthy result for "
                          expected "has_arms?"
                          plain "."
                        end
                      end
                  )

                expect(program).to produce_output_when_run(
                  expected_output
                ).in_color(color_enabled).removing_object_ids
              end
            end
          end

          context "when the inspected version of the actual   value is long" do
            it "produces the correct failure message when used in the negative" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  hash = { a: "lot", of: "keys", and: "things", like: "that", lets: "add", more: "keys" }

                  class << hash
                    def has_mapping?; true; end
                  end

                  expect(hash).not_to have_mapping
                TEST
                program =
                  make_plain_test_program(snippet, color_enabled: color_enabled)

                expected_output =
                  build_expected_output(
                    color_enabled: color_enabled,
                    snippet: "expect(hash).not_to have_mapping",
                    newline_before_expectation: true,
                    expectation:
                      proc do
                        line do
                          plain "                         Expected "
                          actual %|{ a: "lot", of: "keys", and: "things", like: "that", lets: "add", more: "keys" }|
                        end

                        line do
                          plain "not to return a truthy result for "
                          expected "has_mapping?"
                        end
                      end
                  )

                expect(program).to produce_output_when_run(
                  expected_output
                ).in_color(color_enabled).removing_object_ids
              end
            end
          end
        end
      end
    end
  end
end
