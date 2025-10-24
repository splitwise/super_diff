# frozen_string_literal: true

module SuperDiff
  module IntegrationTests
    PROJECT_DIRECTORY = Pathname.new('../../..').expand_path(__dir__)

    def as_both_colored_and_uncolored(&block)
      [true, false].each(&block)
    end

    def make_plain_test_program(
      test,
      color_enabled:,
      super_diff_configuration: {},
      preserve_as_whole_file: false
    )
      TestPrograms::Plain.new(
        test,
        color_enabled: color_enabled,
        super_diff_configuration: super_diff_configuration,
        preserve_as_whole_file: preserve_as_whole_file
      )
    end

    def make_rspec_active_record_program(test, color_enabled:)
      TestPrograms::RSpecActiveRecord.new(test, color_enabled: color_enabled)
    end

    def make_rspec_active_support_program(test, color_enabled:)
      TestPrograms::RSpecActiveSupport.new(test, color_enabled: color_enabled)
    end

    def make_rspec_action_dispatch_program(test, color_enabled:)
      TestPrograms::RSpecActionDispatch.new(test, color_enabled: color_enabled)
    end

    def make_rspec_rails_test_program(test, color_enabled:)
      TestPrograms::RSpecRails.new(test, color_enabled: color_enabled)
    end

    def make_rspec_rails_engine_with_action_controller_program(
      test,
      color_enabled:
    )
      TestPrograms::RspecRailsEngineWithActionController.new(
        test,
        color_enabled: color_enabled
      )
    end

    def build_expected_output(
      color_enabled:,
      snippet:,
      expectation:,
      test_name: 'test passes',
      key_enabled: true,
      newline_before_expectation: false,
      indentation: 7,
      diff: nil,
      extra_failure_lines: nil
    )
      colored(color_enabled: color_enabled) do
        line "Failures:\n"

        line "1) #{test_name}", indent_by: 2

        line indent_by: 5 do
          bold 'Failure/Error: '
          plain snippet
        end

        newline if diff || newline_before_expectation

        indent by: indentation do
          evaluate_block(&expectation)

          if diff
            newline

            white_line 'Diff:'

            if key_enabled
              newline

              line { blue '┌ (Key) ──────────────────────────┐' }

              line do
                blue '│ '
                magenta '‹-› in expected, not in actual'
                blue '  │'
              end

              line do
                blue '│ '
                yellow '‹+› in actual, not in expected'
                blue '  │'
              end

              line do
                blue '│ '
                text '‹ › in both expected and actual'
                blue ' │'
              end

              line { blue '└─────────────────────────────────┘' }
            end

            newline

            evaluate_block(&diff)

            newline
          end
        end

        if extra_failure_lines
          newline
          evaluate_block(&extra_failure_lines)
        end
      end
    end

    def colored(color_enabled: true, &block)
      SuperDiff::Core::Helpers
        .style(color_enabled: color_enabled, &block)
        .to_s
        .chomp
    end
  end
end
