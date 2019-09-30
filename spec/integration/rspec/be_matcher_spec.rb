require "spec_helper"

RSpec.describe "Integration with RSpec's #be matcher", type: :integration do
  context "with a boolean" do
    context "when comparing true and false" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          program =
            make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
              expect(true).to be(false)
            TEST

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(true).to be(false)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|true|
                plain " to equal "
                red %|false|
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

    context "when comparing false and true" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          program =
            make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
              expect(false).to be(true)
            TEST

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(false).to be(true)|,
            expectation: proc {
              line do
                plain "Expected "
                green %|false|
                plain " to equal "
                red %|true|
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
  end

  context "with no arguments" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect(nil).to be
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(nil).to be|,
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

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "with ==" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect(nil).to be == :foo
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(nil).to be == :foo|,
          expectation: proc {
            line do
              plain "Expected "
              green %|nil|
              plain " to == "
              red %|:foo|
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

  context "with <" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect(1).to be < 1
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(1).to be < 1|,
          expectation: proc {
            line do
              plain "Expected "
              green %|1|
              plain " to be < "
              red %|1|
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

  context "with <=" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect(1).to be <= 0
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(1).to be <= 0|,
          expectation: proc {
            line do
              plain "Expected "
              green %|1|
              plain " to be <= "
              red %|0|
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

  context "with >=" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect(1).to be >= 2
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(1).to be >= 2|,
          expectation: proc {
            line do
              plain "Expected "
              green %|1|
              plain " to be >= "
              red %|2|
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

  context "with >" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect(1).to be > 2
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(1).to be > 2|,
          expectation: proc {
            line do
              plain "Expected "
              green %|1|
              plain " to be > "
              red %|2|
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

  context "with ===" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect(:foo).to be === String
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(:foo).to be === String|,
          expectation: proc {
            line do
              plain "Expected "
              green %|:foo|
              plain " to === "
              red %|String|
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

  context "with =~" do
    it "produces the correct output" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect("foo").to be =~ /bar/
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect("foo").to be =~ /bar/|,
          expectation: proc {
            line do
              plain "Expected "
              green %|"foo"|
              plain " to =~ "
              red %|/bar/|
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
end
