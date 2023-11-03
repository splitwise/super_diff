require "spec_helper"

RSpec.describe "Integration with DSL and other RSpec matchers",
               type: :integration do
  let(:matcher_definition) { <<~MATCHER.strip }
      RSpec::Matchers.define :perfect_square do
        match do |actual|
          actual.is_a?(Integer) && actual >= 0 &&
            (Math.sqrt(actual) % 1).zero?
        end
        description { "be a perfect square" }
      end
    MATCHER
  context "when the expected value is a DSL matcher" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          #{matcher_definition}

          expected = perfect_square
          actual = 3
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
                  actual "3"
                  plain " to match "
                  expected "(be a perfect square)"
                  plain "."
                end
              end
            # diff:
            #   proc do
            #     plain_line "  {"
            #     expected_line %|-   city: "Hill Valley"|
            #     actual_line %|+   city: "Burbank"|
            #     plain_line "  }"
            #   end
          )

        expect(program).to produce_output_when_run(expected_output).in_color(
          color_enabled
        )
      end
    end
  end

  context "when the expected value contains a DSL matcher" do
    context "that fails" do
      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            #{matcher_definition}

            expected = hash_including(number: perfect_square)
            actual = {number: 3}
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
                    actual "{ number: 3 }"
                    plain " to match "
                    expected "#<a hash including (number: (be a perfect square))>"
                    plain "."
                  end
                end,
              diff:
                proc do
                  plain_line "  {"
                  expected_line "-   number: (be a perfect square)"
                  actual_line "+   number: 3"
                  plain_line "  }"
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end

    context "that passes while the compound matcher fails" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            #{matcher_definition}
            expected = a_hash_including(
              number: perfect_square,
              string: "hello"
            )
            actual = {
              number: 4,
              string: "goodbye"
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
                    actual %|{ number: 4, string: "goodbye" }|
                  end

                  line do
                    plain "to match "
                    expected %|#<a hash including (number: (be a perfect square), string: "hello")>|
                  end
                end,
              diff:
                proc do
                  plain_line "  {"
                  plain_line "    number: 4,"
                  expected_line %|-   string: "hello"|
                  actual_line %|+   string: "goodbye"|
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
            actual = {
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
end
