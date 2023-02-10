require "spec_helper"

RSpec.describe "Integration with a third-party matcher", type: :integration do
  context "when the matcher is used in the positive and fails" do
    context "when the failure message spans multiple lines" do
      context "and some of the message is indented" do
        it "colorizes the non-indented part in red" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expect(:anything).to fail_with_indented_multiline_failure_message
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet:
                  "expect(:anything).to fail_with_indented_multiline_failure_message",
                newline_before_expectation: true,
                expectation:
                  proc do
                    red_line "This is a message that spans multiple lines."
                    red_line "Here is the next line."
                    plain_line "  This part is indented, for whatever reason. It just kinda keeps"
                    plain_line "  going until we finish saying whatever it is we want to say."
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled)
          end
        end
      end

      context "and some of the message is not indented" do
        context "and the message is divided into paragraphs" do
          it "colorizes the first paragraph in red" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect(:anything).to fail_with_paragraphed_failure_message
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet:
                    "expect(:anything).to fail_with_paragraphed_failure_message",
                  newline_before_expectation: true,
                  expectation:
                    proc do
                      red_line "This is a message that spans multiple paragraphs."
                      newline
                      plain_line "Here is the next paragraph."
                    end
                )

              expect(program).to produce_output_when_run(
                expected_output
              ).in_color(color_enabled)
            end
          end
        end

        context "and the message is not divided into paragraphs" do
          it "colorizes all of the message in red" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect(:anything).to fail_with_non_indented_multiline_failure_message
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet:
                    "expect(:anything).to fail_with_non_indented_multiline_failure_message",
                  newline_before_expectation: true,
                  expectation:
                    proc do
                      red_line "This is a message that spans multiple lines."
                      red_line "Here is the next line."
                    end
                )

              expect(program).to produce_output_when_run(
                expected_output
              ).in_color(color_enabled)
            end
          end
        end
      end
    end

    context "when the failure message does not span multiple lines" do
      it "colorizes all of the message in red" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(:anything).to fail_with_singleline_failure_message
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(:anything).to fail_with_singleline_failure_message",
              expectation:
                proc { red_line "This is a message that spans only one line." }
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end
  end

  context "when the matcher is used in the negative and fails" do
    context "when the failure message spans multiple lines" do
      context "and some of the message is indented" do
        it "colorizes the non-indented part in red" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expect(:anything).not_to pass_with_indented_multiline_failure_message
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet:
                  "expect(:anything).not_to pass_with_indented_multiline_failure_message",
                newline_before_expectation: true,
                expectation:
                  proc do
                    red_line "This is a message that spans multiple lines."
                    red_line "Here is the next line."
                    plain_line "  This part is indented, for whatever reason. It just kinda keeps"
                    plain_line "  going until we finish saying whatever it is we want to say."
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled)
          end
        end
      end

      context "and some of the message is not indented" do
        context "and the message is divided into paragraphs" do
          it "colorizes all of the message in red" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect(:anything).not_to pass_with_paragraphed_failure_message
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet:
                    "expect(:anything).not_to pass_with_paragraphed_failure_message",
                  newline_before_expectation: true,
                  expectation:
                    proc do
                      red_line "This is a message that spans multiple paragraphs."
                      newline
                      plain_line "Here is the next paragraph."
                    end
                )

              expect(program).to produce_output_when_run(
                expected_output
              ).in_color(color_enabled)
            end
          end
        end

        context "and the message is not divided into paragraphs" do
          it "colorizes all of the message in red" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect(:anything).not_to pass_with_non_indented_multiline_failure_message
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet:
                    "expect(:anything).not_to pass_with_non_indented_multiline_failure_message",
                  newline_before_expectation: true,
                  expectation:
                    proc do
                      red_line "This is a message that spans multiple lines."
                      red_line "Here is the next line."
                    end
                )

              expect(program).to produce_output_when_run(
                expected_output
              ).in_color(color_enabled)
            end
          end
        end
      end
    end

    context "when the failure message does not span multiple lines" do
      it "colorizes all of the message in red" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(:anything).not_to pass_with_singleline_failure_message
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(:anything).not_to pass_with_singleline_failure_message",
              expectation:
                proc { red_line "This is a message that spans only one line." }
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end
  end
end
