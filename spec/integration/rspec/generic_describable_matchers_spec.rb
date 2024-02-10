require "spec_helper"

RSpec.describe "Integration with describable matchers not handled specially",
               type: :integration do
  context "when the expected value contains a built-in matcher (not an aliased matcher)" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
            actual = {
              number: "not a number"
            }
            expected = hash_including(
              number: be_a(Numeric)
            )
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
                  actual %|{ number: "not a number" }|
                  plain " to match "
                  expected "#<a hash including (number: #<be a kind of Numeric>)>"
                  plain "."
                end
              end,
            diff:
              proc do
                plain_line "  {"
                expected_line "-   number: #<be a kind of Numeric>"
                actual_line %|+   number: "not a number"|
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
          actual = {
            number: 4
          }
          expected = hash_including(
            number: be_a(Numeric)
          )
          expect(actual).not_to match(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).not_to match(expected)",
            expectation:
              proc do
                line do
                  plain "Expected "
                  actual "{ number: 4 }"
                  plain " not to match "
                  expected "#<a hash including (number: #<be a kind of Numeric>)>"
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

  context "when the expected value contains a custom matcher defined via RSpec::Matchers::DSL" do
    it "produces the correct failure message" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          actual = {
            number: "something else"
          }
          expected = hash_including(
            number: failing_custom_matcher_from_dsl(42)
          )
          expect(actual).to match(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to match(expected)",
            newline_before_expectation: true,
            expectation:
              proc do
                line do
                  plain "Expected "
                  actual %|{ number: "something else" }|
                end

                line do
                  plain "to match "
                  expected "#<a hash including (number: #<custom matcher defined via the DSL with value 42>)>"
                end
              end,
            diff:
              proc do
                plain_line "  {"
                expected_line "-   number: #<custom matcher defined via the DSL with value 42>"
                actual_line %|+   number: "something else"|
                plain_line "  }"
              end
          )

        expect(program).to produce_output_when_run(expected_output).in_color(
          color_enabled
        )
      end
    end
  end

  context "when the expected value contains a custom matcher defined from scratch" do
    it "produces the correct failure message" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          actual = {
            number: "something else"
          }
          expected = hash_including(
            number: failing_custom_matcher_from_scratch(42)
          )
          expect(actual).to match(expected)
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to match(expected)",
            newline_before_expectation: true,
            expectation:
              proc do
                line do
                  plain "Expected "
                  actual %|{ number: "something else" }|
                end

                line do
                  plain "to match "
                  expected "#<a hash including (number: #<custom matcher defined from scratch with value 42>)>"
                end
              end,
            diff:
              proc do
                plain_line "  {"
                expected_line "-   number: #<custom matcher defined from scratch with value 42>"
                actual_line %|+   number: "something else"|
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
