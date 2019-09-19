require "spec_helper"

RSpec.describe "Integration with RSpec's #be matcher", type: :integration do
  context "with a boolean" do
    context "assuming color is enabled" do
      context "when comparing true and false" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST.strip)
            expect(true).to be(false)
          TEST

          expected_output = build_colored_expected_output(
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

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "when comparing false and true" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST.strip)
            expect(false).to be(true)
          TEST

          expected_output = build_colored_expected_output(
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

          expect(program).to produce_output_when_run(expected_output)
        end
      end
    end

    context "if color has been disabled" do
      it "does not include the color in the output" do
        program = make_plain_test_program(<<~TEST.strip, color_enabled: false)
          expect(true).to be(false)
        TEST

        expected_output = build_uncolored_expected_output(
          snippet: %|expect(true).to be(false)|,
          expectation: proc {
            line do
              plain "Expected "
              plain %|true|
              plain " to equal "
              plain %|false|
              plain "."
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end
  end

  context "with no arguments" do
    context "assuming color is enabled" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expect(nil).to be
        TEST

        expected_output = build_colored_expected_output(
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

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "if color has been disabled" do
      it "does not include the color in the output" do
        program = make_plain_test_program(<<~TEST.strip, color_enabled: false)
          expect(nil).to be
        TEST

        expected_output = build_uncolored_expected_output(
          snippet: %|expect(nil).to be|,
          expectation: proc {
            line do
              plain "Expected "
              plain %|nil|
              plain " to be "
              plain %|truthy|
              plain "."
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end
  end

  context "with ==" do
    context "assuming color is enabled" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expect(nil).to be == :foo
        TEST

        expected_output = build_colored_expected_output(
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

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "if color has been disabled" do
      it "does not include the color in the output" do
        program = make_plain_test_program(<<~TEST.strip, color_enabled: false)
          expect(nil).to be == :foo
        TEST

        expected_output = build_uncolored_expected_output(
          snippet: %|expect(nil).to be == :foo|,
          expectation: proc {
            line do
              plain "Expected "
              plain %|nil|
              plain " to == "
              plain %|:foo|
              plain "."
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end
  end

  context "with <" do
    context "assuming color is enabled" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expect(1).to be < 1
        TEST

        expected_output = build_colored_expected_output(
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

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "if color has been disabled" do
      it "does not include the color in the output" do
        program = make_plain_test_program(<<~TEST.strip, color_enabled: false)
          expect(1).to be < 1
        TEST

        expected_output = build_uncolored_expected_output(
          snippet: %|expect(1).to be < 1|,
          expectation: proc {
            line do
              plain "Expected "
              plain %|1|
              plain " to be < "
              plain %|1|
              plain "."
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end
  end

  context "with <=" do
    context "assuming color is enabled" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expect(1).to be <= 0
        TEST

        expected_output = build_colored_expected_output(
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

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "if color has been disabled" do
      it "does not include the color in the output" do
        program = make_plain_test_program(<<~TEST.strip, color_enabled: false)
          expect(1).to be <= 0
        TEST

        expected_output = build_uncolored_expected_output(
          snippet: %|expect(1).to be <= 0|,
          expectation: proc {
            line do
              plain "Expected "
              plain %|1|
              plain " to be <= "
              plain %|0|
              plain "."
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end
  end

  context "with >=" do
    context "assuming color is enabled" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expect(1).to be >= 2
        TEST

        expected_output = build_colored_expected_output(
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

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "if color has been disabled" do
      it "does not include the color in the output" do
        program = make_plain_test_program(<<~TEST.strip, color_enabled: false)
          expect(1).to be >= 2
        TEST

        expected_output = build_uncolored_expected_output(
          snippet: %|expect(1).to be >= 2|,
          expectation: proc {
            line do
              plain "Expected "
              plain %|1|
              plain " to be >= "
              plain %|2|
              plain "."
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end
  end

  context "with >" do
    context "assuming color is enabled" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expect(1).to be > 2
        TEST

        expected_output = build_colored_expected_output(
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

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "if color has been disabled" do
      it "does not include the color in the output" do
        program = make_plain_test_program(<<~TEST.strip, color_enabled: false)
          expect(1).to be > 2
        TEST

        expected_output = build_uncolored_expected_output(
          snippet: %|expect(1).to be > 2|,
          expectation: proc {
            line do
              plain "Expected "
              plain %|1|
              plain " to be > "
              plain %|2|
              plain "."
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end
  end

  context "with ===" do
    context "assuming color is enabled" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expect(:foo).to be === String
        TEST

        expected_output = build_colored_expected_output(
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

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "if color has been disabled" do
      it "does not include the color in the output" do
        program = make_plain_test_program(<<~TEST.strip, color_enabled: false)
          expect(:foo).to be === String
        TEST

        expected_output = build_uncolored_expected_output(
          snippet: %|expect(:foo).to be === String|,
          expectation: proc {
            line do
              plain "Expected "
              plain %|:foo|
              plain " to === "
              plain %|String|
              plain "."
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end
  end

  context "with =~" do
    context "assuming color is enabled" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expect("foo").to be =~ /bar/
        TEST

        expected_output = build_colored_expected_output(
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

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "if color has been disabled" do
      it "does not include the color in the output" do
        program = make_plain_test_program(<<~TEST.strip, color_enabled: false)
          expect("foo").to be =~ /bar/
        TEST

        expected_output = build_uncolored_expected_output(
          snippet: %|expect("foo").to be =~ /bar/|,
          expectation: proc {
            line do
              plain "Expected "
              plain %|"foo"|
              plain " to =~ "
              plain %|/bar/|
              plain "."
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end
  end
end
