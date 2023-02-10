require "spec_helper"

RSpec.describe "Integration with RSpec's #be_truthy matcher",
               type: :integration do
  it "produces the correct failure message when used in the positive" do
    as_both_colored_and_uncolored do |color_enabled|
      program =
        make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
          expect(nil).to be_truthy
        TEST

      expected_output =
        build_expected_output(
          color_enabled: color_enabled,
          snippet: "expect(nil).to be_truthy",
          expectation:
            proc do
              line do
                plain "Expected "
                actual "nil"
                plain " to be "
                expected "truthy"
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
      program =
        make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
          expect(true).not_to be_truthy
        TEST

      expected_output =
        build_expected_output(
          color_enabled: color_enabled,
          snippet: "expect(true).not_to be_truthy",
          expectation:
            proc do
              line do
                plain "Expected "
                actual "true"
                plain " not to be "
                expected "truthy"
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
