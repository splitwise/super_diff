require "spec_helper"

RSpec.describe "Integration with RSpec and unhandled errors", type: :integration do
  context "when a random exception occurs" do
    context "and the message spans multiple lines" do
      it "highlights the first line in red, and then leaves the rest of the message alone" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            raise "Some kind of error or whatever\\n\\nThis is another line"
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|raise "Some kind of error or whatever\\n\\nThis is another line"|,
            newline_before_expectation: true,
            indentation: 5,
            expectation: proc {
              red_line "RuntimeError:"
              indent by: 2 do
                red_line "Some kind of error or whatever"
                newline
                plain_line "This is another line"
              end
            }
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end

    context "and the message does not span multiple lines" do
      it "highlights the whole output after the code snippet in red" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            raise "Some kind of error or whatever"
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|raise "Some kind of error or whatever"|,
            newline_before_expectation: true,
            indentation: 5,
            expectation: proc {
              red_line "RuntimeError:"
              indent by: 2 do
                red_line "Some kind of error or whatever"
              end
            }
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end
  end
end
