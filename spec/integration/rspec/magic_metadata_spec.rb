# frozen_string_literal: true

require 'spec_helper'

RSpec.describe "Integration with RSpec's magic metadata", type: :integration do
  it 'includes extra_failure_lines in failure messages' do
    as_both_colored_and_uncolored do |color_enabled|
      snippet = <<~TEST.strip
        RSpec.describe "test" do
          it { expect(true).to be(false) }

          after do
            RSpec.current_example.metadata[:extra_failure_lines] = "foo\nbar"
          end
        end
      TEST
      program =
        make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
          preserve_as_whole_file: true
        )

      expected_output =
        build_expected_output(
          color_enabled: color_enabled,
          test_name: 'test is expected to equal false',
          snippet: 'it { expect(true).to be(false) }',
          expectation:
            proc do
              line do
                plain 'Expected '
                actual 'true'
                plain ' to equal '
                expected 'false'
                plain '.'
              end
            end,
          extra_failure_lines:
            proc do
              indent by: 5 do
                line 'foo'
                line 'bar'
              end
            end
        )

      expect(program).to produce_output_when_run(expected_output).in_color(
        color_enabled
      )
    end
  end
end
