require "spec_helper"

RSpec.describe "Integration with RSpec's #be matcher", type: :integration do
  context "with a boolean" do
    context "when comparing with false" do
      it "produces the correct failure message when used in the positive" do
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
                beta %|true|
                plain " to equal "
                alpha %|false|
                plain "."
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          program =
            make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
              expect(false).not_to be(false)
            TEST

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(false).not_to be(false)|,
            expectation: proc {
              line do
                plain "Expected "
                beta %|false|
                plain " not to equal "
                alpha %|false|
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

    context "when comparing with true" do
      it "produces the correct failure message when used in the positive" do
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
                beta %|false|
                plain " to equal "
                alpha %|true|
                plain "."
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          program =
            make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
              expect(true).not_to be(true)
            TEST

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(true).not_to be(true)|,
            expectation: proc {
              line do
                plain "Expected "
                beta %|true|
                plain " not to equal "
                alpha %|true|
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
    it "produces the correct failure message when used in the positive" do
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
              beta %|nil|
              plain " to be "
              alpha %|truthy|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect(:something).not_to be
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(:something).not_to be|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|:something|
              plain " not to be "
              alpha %|truthy|
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
    it "produces the correct failure message when used in the positive" do
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
              beta %|nil|
              plain " to == "
              alpha %|:foo|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect(:foo).not_to be == :foo
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(:foo).not_to be == :foo|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|:foo|
              plain " not to == "
              alpha %|:foo|
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
    it "produces the correct failure message when used in the positive" do
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
              beta %|1|
              plain " to be < "
              alpha %|1|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect(0).not_to be < 1
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(0).not_to be < 1|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|0|
              plain " not to be < "
              alpha %|1|
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
    it "produces the correct failure message when used in the positive" do
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
              beta %|1|
              plain " to be <= "
              alpha %|0|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect(0).not_to be <= 0
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(0).not_to be <= 0|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|0|
              plain " not to be <= "
              alpha %|0|
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
    it "produces the correct failure message when used in the positive" do
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
              beta %|1|
              plain " to be >= "
              alpha %|2|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect(2).not_to be >= 2
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(2).not_to be >= 2|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|2|
              plain " not to be >= "
              alpha %|2|
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
    it "produces the correct failure message when used in the positive" do
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
              beta %|1|
              plain " to be > "
              alpha %|2|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect(3).not_to be > 2
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(3).not_to be > 2|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|3|
              plain " not to be > "
              alpha %|2|
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
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect(String).to be === :foo
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(String).to be === :foo|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|String|
              plain " to === "
              alpha %|:foo|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect(String).not_to be === "foo"
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(String).not_to be === "foo"|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|String|
              plain " not to === "
              alpha %|"foo"|
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
    it "produces the correct failure message when used in the positive" do
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
              beta %|"foo"|
              plain " to =~ "
              alpha %|/bar/|
              plain "."
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        program =
          make_plain_test_program(<<~TEST.strip, color_enabled: color_enabled)
            expect("bar").not_to be =~ /bar/
          TEST

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect("bar").not_to be =~ /bar/|,
          expectation: proc {
            line do
              plain "Expected "
              beta %|"bar"|
              plain " not to =~ "
              alpha %|/bar/|
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
