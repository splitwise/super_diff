require "spec_helper"

RSpec.describe "Integration with RSpec's #raise_error matcher", type: :integration do
  context "assuming color is enabled" do
    context "given only an exception class" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST.strip)
          expect { raise StandardError.new('boo') }.to raise_error(RuntimeError)
        TEST

        expected_output = build_colored_expected_output(
          snippet: %|expect { raise StandardError.new('boo') }.to raise_error(RuntimeError)|,
          expectation: proc {
            line do
              plain "Expected raised exception "
              green %|#<StandardError "boo">|
              plain " to match "
              red %|#<RuntimeError>|
              plain "."
            end
          },
        )

        expect(program).to produce_output_when_run(expected_output)
      end
    end

    context "with only a message (and assuming a RuntimeError)" do
      context "when the message is short" do
        it "produces the correct output" do
          program = make_plain_test_program(<<~TEST)
            expect { raise 'boo' }.to raise_error('hell')
          TEST

          expected_output = build_colored_expected_output(
            snippet: %|expect { raise 'boo' }.to raise_error('hell')|,
            expectation: proc {
              line do
                plain "Expected raised exception "
                green %|#<RuntimeError "boo">|
                plain " to match "
                red %|#<Exception "hell">|
                plain "."
              end
            },
          )

          expect(program).to produce_output_when_run(expected_output)
        end
      end

      context "when the message is long" do
        context "but contains no line breaks" do
          it "produces the correct output" do
            program = make_plain_test_program(<<~TEST)
              actual_message = "some really really really long message"
              expected_message = "whatever"
              expect { raise(actual_message) }.to raise_error(expected_message)
            TEST

            expected_output = build_colored_expected_output(
              snippet: %|expect { raise(actual_message) }.to raise_error(expected_message)|,
              newline_before_expectation: true,
              expectation: proc {
                line do
                  plain "Expected raised exception "
                  green %|#<RuntimeError "some really really really long message">|
                end

                line do
                  plain "                 to match "
                  red %|#<Exception "whatever">|
                end
              },
            )

            expect(program).to produce_output_when_run(expected_output)
          end
        end

        context "but contains line breaks" do
          it "produces the correct output" do
            program = make_plain_test_program(<<~TEST)
              actual_message = <<~MESSAGE.rstrip
                This is fun
                So is this
              MESSAGE
              expected_message = <<~MESSAGE.rstrip
                This is fun
                And so is this
              MESSAGE
              expect { raise(actual_message) }.to raise_error(expected_message)
            TEST

            expected_output = build_colored_expected_output(
              snippet: %|expect { raise(actual_message) }.to raise_error(expected_message)|,
              expectation: proc {
                line do
                  plain "Expected raised exception "
                  green %|#<RuntimeError "This is fun\\nSo is this">|
                end

                line do
                  plain "                 to match "
                  red %|#<Exception "This is fun\\nAnd so is this">|
                end
              },
              diff: proc {
                plain_line %|  This is fun\\n|
                red_line   %|- And so is this|
                green_line %|+ So is this|
              },
            )

            expect(program).to produce_output_when_run(expected_output)
          end
        end
      end
    end

    context "with both an exception and a message" do
      it "produces the correct output" do
        program = make_plain_test_program(<<~TEST)
          block = -> { raise StandardError.new('a') }
          expect(&block).to raise_error(RuntimeError, 'b')
        TEST

        expected_output = build_colored_expected_output(
          snippet: %|expect(&block).to raise_error(RuntimeError, 'b')|,
          expectation: proc {
            line do
              plain "Expected raised exception "
              green %|#<StandardError "a">|
              plain " to match "
              red %|#<RuntimeError "b">|
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
      program = make_plain_test_program(<<~TEST, color_enabled: false)
        actual_message = <<~MESSAGE.rstrip
          This is fun
          So is this
        MESSAGE
        expected_message = <<~MESSAGE.rstrip
          This is fun
          And so is this
        MESSAGE
        expect { raise(actual_message) }.to raise_error(expected_message)
      TEST

      expected_output = build_uncolored_expected_output(
        snippet: %|expect { raise(actual_message) }.to raise_error(expected_message)|,
        expectation: proc {
          line do
            plain "Expected raised exception "
            plain %|#<RuntimeError "This is fun\\nSo is this">|
          end

          line do
            plain "                 to match "
            plain %|#<Exception "This is fun\\nAnd so is this">|
          end
        },
        diff: proc {
          plain_line %|  This is fun\\n|
          plain_line %|- And so is this|
          plain_line %|+ So is this|
        },
      )

      expect(program).to produce_output_when_run(expected_output)
    end
  end
end
