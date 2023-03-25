require "spec_helper"

RSpec.describe "Integration with RSpec and unhandled errors",
               type: :integration do
  context "when a random exception occurs" do
    context "and the message spans multiple lines" do
      it "highlights the first line in red, and then leaves the rest of the message alone" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            raise "Some kind of error or whatever\\n\\nThis is another line"
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: snippet,
              newline_before_expectation: true,
              indentation: 5,
              expectation:
                proc do
                  red_line "RuntimeError:"
                  indent by: 2 do
                    red_line "Some kind of error or whatever"
                    newline
                    plain_line "This is another line"
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end

    context "and the message does not span multiple lines" do
      it "highlights the whole output after the code snippet in red" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            raise "Some kind of error or whatever"
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: snippet,
              newline_before_expectation: true,
              indentation: 5,
              expectation:
                proc do
                  red_line "RuntimeError:"
                  indent by: 2 do
                    red_line "Some kind of error or whatever"
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

  context "when multiple exceptions occur" do
    it "displays all exceptions, and for each exception, highlights the first line in red and leaves the rest of the message alone" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          raise "Some kind of error or whatever\\n\\nThis is another line"
        TEST
        code = <<~CODE
          RSpec.describe "test" do
            after(:each) do
              #{snippet}
            end

            it "passes" do
              #{snippet}
            end
          end
        CODE

        program =
          make_plain_test_program(
            code,
            color_enabled: color_enabled,
            preserve_as_whole_file: true
          )

        expected_output1 =
          colored(color_enabled: color_enabled) do
            indent by: 5 do
              line do
                plain "1.1) "
                bold "Failure/Error: "
                plain snippet
              end

              newline

              indent by: 5 do
                red_line "RuntimeError:"
                indent by: 2 do
                  red_line "Some kind of error or whatever"
                  newline
                  line "This is another line"
                end
              end
            end
          end

        expected_output2 =
          colored(color_enabled: color_enabled) do
            indent by: 5 do
              line do
                plain "1.2) "
                bold "Failure/Error: "
                plain snippet
              end

              newline

              indent by: 5 do
                red_line "RuntimeError:"
                indent by: 2 do
                  red_line "Some kind of error or whatever"
                  newline
                  line "This is another line"
                end
              end
            end
          end

        expect(program).to produce_output_when_run(expected_output1).in_color(
          color_enabled
        )

        expect(program).to produce_output_when_run(expected_output2).in_color(
          color_enabled
        )
      end
    end
  end
end
