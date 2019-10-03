require "spec_helper"

RSpec.describe "Integration with RSpec's #raise_error matcher", type: :integration do
  context "given only an exception class" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expect { raise StandardError.new('boo') }.to raise_error(RuntimeError)
        TEST
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect { raise StandardError.new('boo') }.to raise_error(RuntimeError)|,
          expectation: proc {
            line do
              plain "Expected raised exception "
              beta %|#<StandardError "boo">|
              plain " to match "
              alpha %|#<RuntimeError>|
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
        snippet = <<~TEST.strip
          expect { raise StandardError.new('boo') }.not_to raise_error(StandardError)
        TEST
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect { raise StandardError.new('boo') }.not_to raise_error(StandardError)|,
          expectation: proc {
            line do
              plain "Expected raised exception "
              beta %|#<StandardError "boo">|
              plain " not to match "
              alpha %|#<StandardError>|
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

  context "with only a message (and assuming a RuntimeError)" do
    context "when the message is short" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect { raise 'boo' }.to raise_error('hell')
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect { raise 'boo' }.to raise_error('hell')|,
            expectation: proc {
              line do
                plain "Expected raised exception "
                beta %|#<RuntimeError "boo">|
                plain " to match "
                alpha %|#<Exception "hell">|
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
          snippet = <<~TEST.strip
            expect { raise 'boo' }.not_to raise_error('boo')
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect { raise 'boo' }.not_to raise_error('boo')|,
            expectation: proc {
              line do
                plain "Expected raised exception "
                beta %|#<RuntimeError "boo">|
                plain " not to match "
                alpha %|#<Exception "boo">|
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

    context "when the message is long" do
      context "but contains no line breaks" do
        it "produces the correct failure message when used in the positive" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              actual_message = "some really really really long message"
              expected_message = "whatever"
              expect { raise(actual_message) }.to raise_error(expected_message)
            TEST
            program = make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
            )

            expected_output = build_expected_output(
              color_enabled: color_enabled,
              snippet: %|expect { raise(actual_message) }.to raise_error(expected_message)|,
              newline_before_expectation: true,
              expectation: proc {
                line do
                  plain "Expected raised exception "
                  beta %|#<RuntimeError "some really really really long message">|
                end

                line do
                  plain "                 to match "
                  alpha %|#<Exception "whatever">|
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
            snippet = <<~TEST.strip
              message = "some really long message"
              expect { raise(message) }.not_to raise_error(message)
            TEST
            program = make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
            )

            expected_output = build_expected_output(
              color_enabled: color_enabled,
              snippet: %|expect { raise(message) }.not_to raise_error(message)|,
              newline_before_expectation: true,
              expectation: proc {
                line do
                  plain "Expected raised exception "
                  beta %|#<RuntimeError "some really long message">|
                end

                line do
                  plain "             not to match "
                  alpha %|#<Exception "some really long message">|
                end
              },
            )

            expect(program).
              to produce_output_when_run(expected_output).
              in_color(color_enabled)
          end
        end
      end

      context "but contains line breaks" do
        it "produces the correct failure message when used in the positive" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              actual_message = <<\~MESSAGE.rstrip
                This is fun
                So is this
              MESSAGE
              expected_message = <<\~MESSAGE.rstrip
                This is fun
                And so is this
              MESSAGE
              expect { raise(actual_message) }.to raise_error(expected_message)
            TEST
            program = make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
            )

            expected_output = build_expected_output(
              color_enabled: color_enabled,
              snippet: %|expect { raise(actual_message) }.to raise_error(expected_message)|,
              expectation: proc {
                line do
                  plain "Expected raised exception "
                  beta %|#<RuntimeError "This is fun\\nSo is this">|
                end

                line do
                  plain "                 to match "
                  alpha %|#<Exception "This is fun\\nAnd so is this">|
                end
              },
              diff: proc {
                plain_line %|  This is fun\\n|
                alpha_line %|- And so is this|
                beta_line %|+ So is this|
              },
            )

            expect(program).
              to produce_output_when_run(expected_output).
              in_color(color_enabled)
          end
        end

        it "produces the correct failure message when used in the negative" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              message = <<\~MESSAGE.rstrip
                This is fun
                So is this
              MESSAGE
              expect { raise(message) }.not_to raise_error(message)
            TEST
            program = make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
            )

            expected_output = build_expected_output(
              color_enabled: color_enabled,
              snippet: %|expect { raise(message) }.not_to raise_error(message)|,
              newline_before_expectation: true,
              expectation: proc {
                line do
                  plain "Expected raised exception "
                  beta %|#<RuntimeError "This is fun\\nSo is this">|
                end

                line do
                  plain "             not to match "
                  alpha %|#<Exception "This is fun\\nSo is this">|
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
  end

  context "with both an exception and a message" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          block = -> { raise StandardError.new('a') }
          expect(&block).to raise_error(RuntimeError, 'b')
        TEST
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(&block).to raise_error(RuntimeError, 'b')|,
          expectation: proc {
            line do
              plain "Expected raised exception "
              beta %|#<StandardError "a">|
              plain " to match "
              alpha %|#<RuntimeError "b">|
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
        snippet = <<~TEST.strip
          block = -> { raise StandardError.new('a') }
          expect(&block).not_to raise_error(StandardError, 'a')
        TEST
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(&block).not_to raise_error(StandardError, 'a')|,
          expectation: proc {
            line do
              plain "Expected raised exception "
              beta %|#<StandardError "a">|
              plain " not to match "
              alpha %|#<StandardError "a">|
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
