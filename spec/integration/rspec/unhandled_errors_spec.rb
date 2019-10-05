require "spec_helper"

RSpec.describe "Integration with RSpec and unhandled errors", type: :integration do
  context "when a random exception occurs" do
    it "highlights the whole output after the code snippet in red" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          raise "Some kind of error or whatever"
        TEST
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = colored(color_enabled: color_enabled) do
          line "Failures:\n"

          line "1) test passes", indent_by: 2

          line indent_by: 5 do
            bold "Failure/Error: "
            plain %|raise "Some kind of error or whatever"|
          end

          newline

          indent by: 5 do
            red_line "RuntimeError:"
            plain_line "  Some kind of error or whatever"
          end
        end

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when a matcher that has a multi-line message fails" do
    it "highlights the first line of the failure message in red" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          RSpec::Matchers.define :fail_with_multiline_message do
            match do
              false
            end

            failure_message do
              <<\~MESSAGE
                First line

                Second line

                Third line
              MESSAGE
            end
          end

          expect(:foo).to fail_with_multiline_message
        TEST
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = colored(color_enabled: color_enabled) do
          line "Failures:\n"

          line "1) test passes", indent_by: 2

          line indent_by: 5 do
            bold "Failure/Error: "
            plain %|expect(:foo).to fail_with_multiline_message|
          end

          newline

          indent by: 5 do
            red_line "  First line"
            newline
            plain_line "  Second line"
            newline
            plain_line "  Third line"
          end
        end

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end
end
