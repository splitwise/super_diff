require "spec_helper"

RSpec.describe "Integration with RSpec's #be_falsey matcher", type: :integration do
  it "produces the correct failure message" do
    as_both_colored_and_uncolored do |color_enabled|
      snippet = %|expect(:foo).to be_falsey|
      program = make_plain_test_program(snippet, color_enabled: color_enabled)

      expected_output = build_expected_output(
        color_enabled: color_enabled,
        snippet: snippet,
        expectation: proc {
          line do
            plain "Expected "
            green %|:foo|
            plain " to be "
            red %|falsey|
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
