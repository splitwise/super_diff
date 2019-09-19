require "spec_helper"

RSpec.describe "Integration with RSpec's #be_truthy matcher", type: :integration do
  context "assuming color is enabled" do
    it "produces the correct output" do
      program = make_plain_test_program(<<~TEST.strip)
        expect(nil).to be_truthy
      TEST

      expected_output = build_colored_expected_output(
        snippet: %|expect(nil).to be_truthy|,
        expectation: proc {
          line do
            plain "Expected "
            green %|nil|
            plain " to be "
            red %|truthy|
            plain "."
          end
        },
      )

      expect(program).to produce_output_when_run(expected_output)
    end
  end

  context "if color has been disabled" do
    it "does not include the color in the output" do
      program = make_plain_test_program(<<~TEST.strip, color_enabled: false)
        expect(nil).to be_truthy
      TEST

      expected_output = build_uncolored_expected_output(
        snippet: %|expect(nil).to be_truthy|,
        expectation: proc {
          line do
            plain "Expected "
            plain %|nil|
            plain " to be "
            plain %|truthy|
            plain "."
          end
        },
      )

      expect(program).to produce_output_when_run(expected_output)
    end
  end
end
