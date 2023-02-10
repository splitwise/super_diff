shared_examples_for "integration with ActiveSupport" do
  context "when comparing two different Time and ActiveSupport::TimeWithZone instances",
          active_record: true do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~RUBY
          expected = Time.utc(2011, 12, 13, 14, 15, 16)
          actual   = Time.utc(2011, 12, 13, 15, 15, 16).in_time_zone("Europe/Stockholm")
          expect(expected).to eq(actual)
        RUBY
        program =
          make_rspec_rails_test_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(expected).to eq(actual)",
            expectation:
              proc do
                line do
                  plain "Expected "
                  actual "#<Time 2011-12-13 14:15:16 +00:00 (UTC)>"
                end

                line do
                  plain "   to eq "
                  expected "#<ActiveSupport::TimeWithZone 2011-12-13 16:15:16 +01:00 (CET)>"
                end
              end,
            diff:
              proc do
                plain_line "  #<Time {"
                plain_line "    year: 2011,"
                plain_line "    month: 12,"
                plain_line "    day: 13,"
                expected_line "-   hour: 16,"
                actual_line "+   hour: 14,"
                plain_line "    min: 15,"
                plain_line "    sec: 16,"
                plain_line "    subsec: 0,"
                expected_line %|-   zone: \"CET\",|
                actual_line %|+   zone: \"UTC\",|
                expected_line "-   utc_offset: 3600,"
                actual_line "+   utc_offset: 0,"
                plain_line "    utc: #<Time {"
                plain_line "      year: 2011,"
                plain_line "      month: 12,"
                plain_line "      day: 13,"
                expected_line "-     hour: 15,"
                actual_line "+     hour: 14,"
                plain_line "      min: 15,"
                plain_line "      sec: 16,"
                plain_line "      subsec: 0,"
                plain_line %|      zone: "UTC",|
                plain_line "      utc_offset: 0"
                plain_line "    }>"
                plain_line "  }>"
              end
          )

        expect(program).to produce_output_when_run(expected_output).in_color(
          color_enabled
        )
      end
    end
  end
end
