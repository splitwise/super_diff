module SuperDiff
  module IntegrationTests
    PROJECT_DIRECTORY = Pathname.new("../../..").expand_path(__dir__)

    def as_both_colored_and_uncolored
      [true, false].each do |color_enabled|
        yield color_enabled
      end
    end

    def make_plain_test_program(
      test,
      color_enabled:,
      configuration: {},
      preserve_as_whole_file: false
    )
      TestPrograms::Plain.new(
        test,
        color_enabled: color_enabled,
        configuration: configuration,
        preserve_as_whole_file: preserve_as_whole_file,
      )
    end

    def make_rspec_active_record_program(test, color_enabled:)
      TestPrograms::RSpecActiveRecord.new(test, color_enabled: color_enabled)
    end

    def make_rspec_active_support_program(test, color_enabled:)
      TestPrograms::RSpecActiveSupport.new(test, color_enabled: color_enabled)
    end

    def make_rspec_rails_test_program(test, color_enabled:)
      TestPrograms::RSpecRails.new(test, color_enabled: color_enabled)
    end

    def build_expected_output(
      color_enabled:,
      snippet:,
      expectation:,
      newline_before_expectation: false,
      indentation: 7,
      diff: nil
    )
      colored(color_enabled: color_enabled) do
        line "Failures:\n"

        line "1) test passes", indent_by: 2

        line indent_by: 5 do
          bold "Failure/Error: "
          plain snippet
        end

        if diff || newline_before_expectation
          newline
        end

        indent by: indentation do
          evaluate_block(&expectation)

          if diff
            newline

            white_line "Diff:"

            newline

            line do
              blue "┌ (Key) ──────────────────────────┐"
            end

            line do
              blue "│ "
              magenta "‹-› in expected, not in actual"
              blue "  │"
            end

            line do
              blue "│ "
              yellow "‹+› in actual, not in expected"
              blue "  │"
            end

            line do
              blue "│ "
              text "‹ › in both expected and actual"
              blue " │"
            end

            line do
              blue "└─────────────────────────────────┘"
            end

            newline

            evaluate_block(&diff)

            newline
          end
        end
      end
    end

    def colored(color_enabled: true, &block)
      SuperDiff::Helpers.style(color_enabled: color_enabled, &block).to_s.chomp
    end
  end
end
