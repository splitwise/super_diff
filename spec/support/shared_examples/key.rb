shared_examples_for "a matcher that supports a toggleable key" do
  context "if key_enabled is set to true" do
    it "produces the key" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = [
            "Afghanistan",
            "Aland Islands",
            "Albania"
          ]
          actual = [
            "Afghanistan",
            "Aland Islands",
            "Australia"
          ]
          expect(actual).to #{matcher}(expected)
        TEST
        program =
          make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
            configuration: {
              key_enabled: true
            }
          )

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(actual).to #{matcher}(expected)|,
            newline_before_expectation: true,
            expectation:
              proc do
                line do
                  plain "Expected "
                  actual %|["Afghanistan", "Aland Islands", "Australia"]|
                end

                line do
                  plain "   to eq "
                  expected %|["Afghanistan", "Aland Islands", "Albania"]|
                end
              end,
            diff:
              proc do
                plain_line "  ["
                plain_line %|    "Afghanistan",|
                plain_line %|    "Aland Islands",|
                expected_line %|-   "Albania"|
                actual_line %|+   "Australia"|
                plain_line "  ]"
              end,
            key_enabled: true
          )

        expect(program).to produce_output_when_run(expected_output).in_color(
          color_enabled
        )
      end
    end
  end

  context "if key_enabled is set to false" do
    it "does not produce the key" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = [
            "Afghanistan",
            "Aland Islands",
            "Albania"
          ]
          actual = [
            "Afghanistan",
            "Aland Islands",
            "Australia"
          ]
          expect(actual).to #{matcher}(expected)
        TEST
        program =
          make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
            configuration: {
              key_enabled: false
            }
          )

        expected_output =
          build_expected_output(
            key_enabled: false,
            color_enabled: color_enabled,
            snippet: %|expect(actual).to #{matcher}(expected)|,
            newline_before_expectation: true,
            expectation:
              proc do
                line do
                  plain "Expected "
                  actual %|["Afghanistan", "Aland Islands", "Australia"]|
                end

                line do
                  plain "   to eq "
                  expected %|["Afghanistan", "Aland Islands", "Albania"]|
                end
              end,
            diff:
              proc do
                plain_line "  ["
                plain_line %|    "Afghanistan",|
                plain_line %|    "Aland Islands",|
                expected_line %|-   "Albania"|
                actual_line %|+   "Australia"|
                plain_line "  ]"
              end
          )

        expect(program).to produce_output_when_run(expected_output).in_color(
          color_enabled
        )
      end
    end
  end
end
