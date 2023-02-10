require "spec_helper"

RSpec.describe "Integration with RSpec's #raise_error matcher",
               type: :integration do
  context "given only an exception class" do
    context "when used in the positive" do
      context "when the block raises a different error than what is given" do
        context "when the message is short" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect { raise StandardError.new('boo') }.to raise_error(RuntimeError)
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet:
                    "expect { raise StandardError.new('boo') }.to raise_error(RuntimeError)",
                  expectation:
                    proc do
                      line do
                        plain "Expected raised exception "
                        actual %|#<StandardError "boo">|
                        plain " to match "
                        expected "#<RuntimeError>"
                        plain "."
                      end
                    end
                )

              expect(program).to produce_output_when_run(
                expected_output
              ).in_color(color_enabled)
            end
          end
        end

        context "when the message is long" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect { raise StandardError.new('this is a super super super long message') }.to raise_error(RuntimeError)
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet:
                    "expect { raise StandardError.new('this is a super super super long message') }.to raise_error(RuntimeError)",
                  newline_before_expectation: true,
                  expectation:
                    proc do
                      line do
                        plain "Expected raised exception "
                        actual %|#<StandardError "this is a super super super long message">|
                      end

                      line do
                        plain "                 to match "
                        expected "#<RuntimeError>"
                      end
                    end
                )

              expect(program).to produce_output_when_run(
                expected_output
              ).in_color(color_enabled)
            end
          end
        end
      end

      context "when the block raises no error" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expect { }.to raise_error(RuntimeError)
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect { }.to raise_error(RuntimeError)",
                expectation:
                  proc do
                    line do
                      plain "Expected block to raise error "
                      expected "#<RuntimeError>"
                      plain "."
                    end
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled)
          end
        end
      end
    end

    context "when used in the negative" do
      context "when the message is short" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expect { raise StandardError.new('boo') }.not_to raise_error(StandardError)
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet:
                  "expect { raise StandardError.new('boo') }.not_to raise_error(StandardError)",
                expectation:
                  proc do
                    line do
                      plain "Expected raised exception "
                      actual %|#<StandardError "boo">|
                      plain " not to match "
                      expected "#<StandardError>"
                      plain "."
                    end
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled)
          end
        end
      end

      context "when the message is long" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expect { raise StandardError.new('this is a super super long message') }.not_to raise_error(StandardError)
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet:
                  "expect { raise StandardError.new('this is a super super long message') }.not_to raise_error(StandardError)",
                newline_before_expectation: true,
                expectation:
                  proc do
                    line do
                      plain "Expected raised exception "
                      actual %|#<StandardError "this is a super super long message">|
                    end

                    line do
                      plain "             not to match "
                      expected "#<StandardError>"
                    end
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

  context "with only a message (and assuming a RuntimeError)" do
    context "when used in the positive" do
      context "when the block raises a different error than what is given" do
        context "when the message is short" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect { raise 'boo' }.to raise_error('hell')
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet: "expect { raise 'boo' }.to raise_error('hell')",
                  expectation:
                    proc do
                      line do
                        plain "Expected raised exception "
                        actual %|#<RuntimeError "boo">|
                        plain " to match "
                        expected %|#<Exception "hell">|
                        plain "."
                      end
                    end
                )

              expect(program).to produce_output_when_run(
                expected_output
              ).in_color(color_enabled)
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
                program =
                  make_plain_test_program(snippet, color_enabled: color_enabled)

                expected_output =
                  build_expected_output(
                    color_enabled: color_enabled,
                    snippet:
                      "expect { raise(actual_message) }.to raise_error(expected_message)",
                    newline_before_expectation: true,
                    expectation:
                      proc do
                        line do
                          plain "Expected raised exception "
                          actual %|#<RuntimeError "some really really really long message">|
                        end

                        line do
                          plain "                 to match "
                          expected %|#<Exception "whatever">|
                        end
                      end
                  )

                expect(program).to produce_output_when_run(
                  expected_output
                ).in_color(color_enabled)
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
                program =
                  make_plain_test_program(snippet, color_enabled: color_enabled)

                expected_output =
                  build_expected_output(
                    color_enabled: color_enabled,
                    snippet:
                      "expect { raise(actual_message) }.to raise_error(expected_message)",
                    expectation:
                      proc do
                        line do
                          plain "Expected raised exception "
                          actual %|#<RuntimeError "This is fun\\nSo is this">|
                        end

                        line do
                          plain "                 to match "
                          expected %|#<Exception "This is fun\\nAnd so is this">|
                        end
                      end,
                    diff:
                      proc do
                        plain_line %|  This is fun\\n|
                        expected_line "- And so is this"
                        actual_line "+ So is this"
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

      context "when the block raises no error" do
        context "when the message is short" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect { }.to raise_error('hell')
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet: "expect { }.to raise_error('hell')",
                  expectation:
                    proc do
                      line do
                        plain "Expected block to raise error "
                        expected %|#<Exception "hell">|
                        plain "."
                      end
                    end
                )

              expect(program).to produce_output_when_run(
                expected_output
              ).in_color(color_enabled)
            end
          end
        end

        context "when the message is long" do
          context "but contains no line breaks" do
            it "produces the correct failure message" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  expect { }.to raise_error("this is a super super super super super super long message")
                TEST
                program =
                  make_plain_test_program(snippet, color_enabled: color_enabled)

                expected_output =
                  build_expected_output(
                    color_enabled: color_enabled,
                    snippet:
                      %|expect { }.to raise_error("this is a super super super super super super long message")|,
                    newline_before_expectation: true,
                    expectation:
                      proc do
                        line do
                          plain "      Expected "
                          plain "block"
                        end

                        line do
                          plain "to raise error "
                          expected %|#<Exception "this is a super super super super super super long message">|
                        end
                      end
                  )

                expect(program).to produce_output_when_run(
                  expected_output
                ).in_color(color_enabled)
              end
            end
          end

          context "but contains line breaks" do
            it "produces the correct failure message when used in the negative" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  message = "some really long message"
                  expect { raise(message) }.not_to raise_error(message)
                TEST
                program =
                  make_plain_test_program(snippet, color_enabled: color_enabled)

                expected_output =
                  build_expected_output(
                    color_enabled: color_enabled,
                    snippet:
                      "expect { raise(message) }.not_to raise_error(message)",
                    newline_before_expectation: true,
                    expectation:
                      proc do
                        line do
                          plain "Expected raised exception "
                          actual %|#<RuntimeError "some really long message">|
                        end

                        line do
                          plain "             not to match "
                          expected %|#<Exception "some really long message">|
                        end
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
    end

    context "when used in the negative" do
      context "when the message is short" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expect { raise 'boo' }.not_to raise_error('boo')
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect { raise 'boo' }.not_to raise_error('boo')",
                expectation:
                  proc do
                    line do
                      plain "Expected raised exception "
                      actual %|#<RuntimeError "boo">|
                      plain " not to match "
                      expected %|#<Exception "boo">|
                      plain "."
                    end
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled)
          end
        end
      end

      context "when the message is long" do
        context "but contains no line breaks" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                message = "some really long message"
                expect { raise(message) }.not_to raise_error(message)
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet:
                    "expect { raise(message) }.not_to raise_error(message)",
                  newline_before_expectation: true,
                  expectation:
                    proc do
                      line do
                        plain "Expected raised exception "
                        actual %|#<RuntimeError "some really long message">|
                      end

                      line do
                        plain "             not to match "
                        expected %|#<Exception "some really long message">|
                      end
                    end
                )

              expect(program).to produce_output_when_run(
                expected_output
              ).in_color(color_enabled)
            end
          end
        end

        context "but contains line breaks" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                message = <<\~MESSAGE.rstrip
                  This is fun
                  So is this
                MESSAGE
                expect { raise(message) }.not_to raise_error(message)
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet:
                    "expect { raise(message) }.not_to raise_error(message)",
                  newline_before_expectation: true,
                  expectation:
                    proc do
                      line do
                        plain "Expected raised exception "
                        actual %|#<RuntimeError "This is fun\\nSo is this">|
                      end

                      line do
                        plain "             not to match "
                        expected %|#<Exception "This is fun\\nSo is this">|
                      end
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
  end

  context "with both an exception and a message" do
    context "when used in the positive" do
      context "when the block raises a different error than what is given" do
        context "when the message is short" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                block = -> { raise StandardError.new('a') }
                expect(&block).to raise_error(RuntimeError, 'b')
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet: "expect(&block).to raise_error(RuntimeError, 'b')",
                  expectation:
                    proc do
                      line do
                        plain "Expected raised exception "
                        actual %|#<StandardError "a">|
                        plain " to match "
                        expected %|#<RuntimeError "b">|
                        plain "."
                      end
                    end
                )

              expect(program).to produce_output_when_run(
                expected_output
              ).in_color(color_enabled)
            end
          end
        end

        context "when the message is long" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                block = -> { raise StandardError.new('this is a long message') }
                expect(&block).to raise_error(RuntimeError, 'this is another long message')
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet:
                    "expect(&block).to raise_error(RuntimeError, 'this is another long message')",
                  newline_before_expectation: true,
                  expectation:
                    proc do
                      line do
                        plain "Expected raised exception "
                        actual %|#<StandardError "this is a long message">|
                      end

                      line do
                        plain "                 to match "
                        expected %|#<RuntimeError "this is another long message">|
                      end
                    end
                )

              expect(program).to produce_output_when_run(
                expected_output
              ).in_color(color_enabled)
            end
          end
        end
      end

      context "when the block raises no error" do
        context "when the message is short" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect { }.to raise_error(RuntimeError, 'b')
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet: "expect { }.to raise_error(RuntimeError, 'b')",
                  expectation:
                    proc do
                      line do
                        plain "Expected block to raise error "
                        expected %|#<RuntimeError "b">|
                        plain "."
                      end
                    end
                )

              expect(program).to produce_output_when_run(
                expected_output
              ).in_color(color_enabled)
            end
          end
        end

        context "when the message is long" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect { }.to raise_error(RuntimeError, 'this is a super super super super super super long message')
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet:
                    "expect { }.to raise_error(RuntimeError, 'this is a super super super super super super long message')",
                  newline_before_expectation: true,
                  expectation:
                    proc do
                      line do
                        plain "      Expected "
                        plain "block"
                      end

                      line do
                        plain "to raise error "
                        expected %|#<RuntimeError "this is a super super super super super super long message">|
                      end
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

    context "when used in the negative" do
      context "when the message is short" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              block = -> { raise StandardError.new('a') }
              expect(&block).not_to raise_error(StandardError, 'a')
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet:
                  "expect(&block).not_to raise_error(StandardError, 'a')",
                expectation:
                  proc do
                    line do
                      plain "Expected raised exception "
                      actual %|#<StandardError "a">|
                      plain " not to match "
                      expected %|#<StandardError "a">|
                      plain "."
                    end
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled)
          end
        end
      end

      context "when the message is long" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              block = -> { raise StandardError.new('this is a long message') }
              expect(&block).not_to raise_error(StandardError, 'this is a long message')
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet:
                  "expect(&block).not_to raise_error(StandardError, 'this is a long message')",
                newline_before_expectation: true,
                expectation:
                  proc do
                    line do
                      plain "Expected raised exception "
                      actual %|#<StandardError "this is a long message">|
                    end

                    line do
                      plain "             not to match "
                      expected %|#<StandardError "this is a long message">|
                    end
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
end
