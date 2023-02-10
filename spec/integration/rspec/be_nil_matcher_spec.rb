require "spec_helper"

RSpec.describe "Integration with RSpec's #be_nil matcher", type: :integration do
  it "produces the correct failure message when used the positive" do
    as_both_colored_and_uncolored do |color_enabled|
      snippet = "expect(:foo).to be_nil"
      program = make_plain_test_program(snippet, color_enabled: color_enabled)

      expected_output =
        build_expected_output(
          color_enabled: color_enabled,
          snippet: "expect(:foo).to be_nil",
          expectation:
            proc do
              line do
                plain "Expected "
                actual ":foo"
                plain " to be "
                expected "nil"
                plain "."
              end
            end
        )

      expect(program).to produce_output_when_run(expected_output).in_color(
        color_enabled
      )
    end
  end

  it "produces the correct failure message when used in the negative" do
    as_both_colored_and_uncolored do |color_enabled|
      snippet = "expect(nil).not_to be_nil"
      program = make_plain_test_program(snippet, color_enabled: color_enabled)

      expected_output =
        build_expected_output(
          color_enabled: color_enabled,
          snippet: "expect(nil).not_to be_nil",
          expectation:
            proc do
              line do
                plain "Expected "
                actual "nil"
                plain " not to be "
                expected "nil"
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
