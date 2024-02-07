require "spec_helper"

RSpec.describe "Integration with RSpec's #raise_error matcher",
               type: :integration do
  context "given only an exception class" do
    context "when used in the positive" do
      context "when the block raises a different error than what is given" do
        context "when the actual message is short" do
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
                        expected "a kind of RuntimeError"
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

        context "when the actual message is long" do
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
                        expected "a kind of RuntimeError"
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
                      plain "Expected "
                      actual "exception-free block"
                      plain " to raise "
                      expected "a kind of RuntimeError"
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
      context "when the actual message is short" do
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
                      expected "a kind of StandardError"
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

      context "when the actual message is long" do
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
                      expected "a kind of StandardError"
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

  context "given only a string message" do
    context "when used in the positive" do
      context "when the block raises a different error than what is given" do
        context "when the expected and/or actual message is short" do
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
                        expected %|a kind of Exception with message "hell"|
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

        context "when the expected and/or actual message is long" do
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
                          expected %|a kind of Exception with message "whatever"|
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
                          expected %|a kind of Exception with message "This is fun\\nAnd so is this"|
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
        context "when the expected message is short" do
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
                        plain "Expected "
                        actual "exception-free block"
                        plain " to raise "
                        expected %|a kind of Exception with message "hell"|
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

        context "when the expected message is long" do
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
                        # stree-ignore
                        line do
                          plain "Expected "
                          actual "exception-free block"
                        end

                        line do
                          plain "to raise "
                          expected %|a kind of Exception with message "this is a super super super super super super long message"|
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
                  expected_message = <<\~MESSAGE.rstrip
                    this is a super super
                    super super super
                    super long message
                  MESSAGE
                  expect { }.to raise_error(expected_message)
                TEST
                program =
                  make_plain_test_program(snippet, color_enabled: color_enabled)

                expected_output =
                  build_expected_output(
                    color_enabled: color_enabled,
                    snippet: "expect { }.to raise_error(expected_message)",
                    newline_before_expectation: true,
                    expectation:
                      proc do
                        # stree-ignore
                        line do
                          plain "Expected "
                          actual "exception-free block"
                        end

                        line do
                          plain "to raise "
                          expected %|a kind of Exception with message "this is a super super\\nsuper super super\\nsuper long message"|
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
      context "when the expected and/or actual message is short" do
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
                      expected %|a kind of Exception with message "boo"|
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

      context "when the expected and/or actual message is long" do
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
                        expected %|a kind of Exception with message "some really long message"|
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
                  this is a super super
                  super super super
                  super long message
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
                        actual %|#<RuntimeError "this is a super super\\nsuper super super\\nsuper long message">|
                      end

                      line do
                        plain "             not to match "
                        expected %|a kind of Exception with message "this is a super super\\nsuper super super\\nsuper long message"|
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

  context "given only a regexp message" do
    context "when used in the positive" do
      context "when the block raises a different error than what is given" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
                expect { raise 'boo' }.to raise_error(/hell/i)
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect { raise 'boo' }.to raise_error(/hell/i)",
                newline_before_expectation: true,
                expectation:
                  proc do
                    line do
                      plain "Expected raised exception "
                      actual %|#<RuntimeError "boo">|
                    end

                    line do
                      plain "                 to match "
                      expected "a kind of Exception with message matching /hell/i"
                    end
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled)
          end
        end
      end

      context "when the block raises no error" do
        context "when the expected message is short" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect { }.to raise_error(/hell/i)
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet: "expect { }.to raise_error(/hell/i)",
                  expectation:
                    proc do
                      line do
                        plain "Expected "
                        actual "exception-free block"
                        plain " to raise "
                        expected "a kind of Exception with message matching /hell/i"
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

        context "when the expected message is long" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect { }.to raise_error(/this is a super super super super super super long message/i)
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet:
                    "expect { }.to raise_error(/this is a super super super super super super long message/i)",
                  newline_before_expectation: true,
                  expectation:
                    proc do
                      line do
                        plain "Expected "
                        actual "exception-free block"
                      end

                      line do
                        plain "to raise "
                        expected "a kind of Exception with message matching /this is a super super super super super super long message/i"
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
      it "produces the correct failure message" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect { raise 'boo' }.not_to raise_error(/boo/i)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect { raise 'boo' }.not_to raise_error(/boo/i)",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "Expected raised exception "
                    actual %|#<RuntimeError "boo">|
                  end

                  line do
                    plain "             not to match "
                    expected "a kind of Exception with message matching /boo/i"
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end
  end

  context "given both an exception class and string message" do
    context "when used in the positive" do
      context "when the block raises a different error than what is given" do
        context "when the expected and/or actual message is short" do
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
                        expected %|a kind of RuntimeError with message "b"|
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

        context "when the expected and/or actual message is long" do
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
                        expected %|a kind of RuntimeError with message "this is another long message"|
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
        context "when the expected message is short" do
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
                        plain "Expected "
                        actual "exception-free block"
                        plain " to raise "
                        expected %|a kind of RuntimeError with message "b"|
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

        context "when the expected message is long" do
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
                        plain "Expected "
                        actual "exception-free block"
                      end

                      line do
                        plain "to raise "
                        expected %|a kind of RuntimeError with message "this is a super super super super super super long message"|
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
              snippet: "expect(&block).not_to raise_error(StandardError, 'a')",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "Expected raised exception "
                    actual %|#<StandardError "a">|
                  end

                  line do
                    plain "             not to match "
                    expected %|a kind of StandardError with message "a"|
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end
  end

  context "given both an exception class and regexp message" do
    context "when used in the positive" do
      context "when the block raises a different error than what is given" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              block = -> { raise StandardError.new('a') }
              expect(&block).to raise_error(RuntimeError, /b/i)
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(&block).to raise_error(RuntimeError, /b/i)",
                newline_before_expectation: true,
                expectation:
                  proc do
                    line do
                      plain "Expected raised exception "
                      actual %|#<StandardError "a">|
                    end

                    line do
                      plain "                 to match "
                      expected "a kind of RuntimeError with message matching /b/i"
                    end
                  end
              )

            expect(program).to produce_output_when_run(
              expected_output
            ).in_color(color_enabled)
          end
        end
      end

      context "when the block raises no error" do
        context "when the expected message is short" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect { }.to raise_error(RuntimeError, /b/i)
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet: "expect { }.to raise_error(RuntimeError, /b/i)",
                  expectation:
                    proc do
                      line do
                        plain "Expected "
                        actual "exception-free block"
                        plain " to raise "
                        expected "a kind of RuntimeError with message matching /b/i"
                      end
                    end
                )

              expect(program).to produce_output_when_run(
                expected_output
              ).in_color(color_enabled)
            end
          end
        end

        context "when the expected message is long" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect { }.to raise_error(RuntimeError, /this is a super super super super super super long message/i)
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet:
                    "expect { }.to raise_error(RuntimeError, /this is a super super super super super super long message/i)",
                  newline_before_expectation: true,
                  expectation:
                    proc do
                      line do
                        plain "Expected "
                        actual "exception-free block"
                      end

                      line do
                        plain "to raise "
                        expected "a kind of RuntimeError with message matching /this is a super super super super super super long message/i"
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
      it "produces the correct failure message" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
              block = -> { raise StandardError.new('a') }
              expect(&block).not_to raise_error(StandardError, /a/i)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(&block).not_to raise_error(StandardError, /a/i)",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "Expected raised exception "
                    actual %|#<StandardError "a">|
                  end

                  line do
                    plain "             not to match "
                    expected "a kind of StandardError with message matching /a/i"
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end
  end

  context "given a simple RSpec fuzzy object" do
    context "when used in the positive" do
      context "when the block raises a different error than what is given" do
        context "when the expected error and/or actual message is short" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect { raise StandardError.new('boo') }.to raise_error(a_kind_of(Array))
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet:
                    "expect { raise StandardError.new('boo') }.to raise_error(a_kind_of(Array))",
                  expectation:
                    proc do
                      line do
                        plain "Expected raised exception "
                        actual %|#<StandardError "boo">|
                        plain " to match "
                        expected "#<a kind of Array>"
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

        context "when the expected error and/or actual message is long" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expect { raise StandardError.new('this is a super super super long message') }.to raise_error(a_kind_of(RuntimeError))
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet:
                    "expect { raise StandardError.new('this is a super super super long message') }.to raise_error(a_kind_of(RuntimeError))",
                  newline_before_expectation: true,
                  expectation:
                    proc do
                      line do
                        plain "Expected raised exception "
                        actual %|#<StandardError "this is a super super super long message">|
                      end

                      line do
                        plain "                 to match "
                        expected "#<a kind of RuntimeError>"
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
              expect { }.to raise_error(a_kind_of(RuntimeError))
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect { }.to raise_error(a_kind_of(RuntimeError))",
                expectation:
                  proc do
                    line do
                      plain "Expected "
                      actual "exception-free block"
                      plain " to raise "
                      expected "#<a kind of RuntimeError>"
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
      context "when the expected error and/or actual message is short" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expect { raise StandardError.new('boo') }.not_to raise_error(a_kind_of(StandardError))
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet:
                  "expect { raise StandardError.new('boo') }.not_to raise_error(a_kind_of(StandardError))",
                expectation:
                  proc do
                    line do
                      plain "Expected raised exception "
                      actual %|#<StandardError "boo">|
                      plain " not to match "
                      expected "#<a kind of StandardError>"
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

      context "when the expected error and/or actual message is long" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expect { raise StandardError.new('this is a super super long message') }.not_to raise_error(a_kind_of(StandardError))
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet:
                  "expect { raise StandardError.new('this is a super super long message') }.not_to raise_error(a_kind_of(StandardError))",
                newline_before_expectation: true,
                expectation:
                  proc do
                    line do
                      plain "Expected raised exception "
                      actual %|#<StandardError "this is a super super long message">|
                    end

                    line do
                      plain "             not to match "
                      expected "#<a kind of StandardError>"
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

  context "given only a simple RSpec fuzzy object and string message" do
    context "when used in the positive" do
      context "when the block raises a different error than what is given" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expect { raise StandardError.new('boo') }.to raise_error(a_kind_of(RuntimeError), "boo")
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet:
                  %|expect { raise StandardError.new('boo') }.to raise_error(a_kind_of(RuntimeError), "boo")|,
                newline_before_expectation: true,
                expectation:
                  proc do
                    line do
                      plain "Expected raised exception "
                      actual %|#<StandardError "boo">|
                    end

                    line do
                      plain "                 to match "
                      expected %|#<a kind of RuntimeError> with message "boo"|
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
      it "produces the correct failure message" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect { raise StandardError.new('boo') }.not_to raise_error(a_kind_of(StandardError), "boo")
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                %|expect { raise StandardError.new('boo') }.not_to raise_error(a_kind_of(StandardError), "boo")|,
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "Expected raised exception "
                    actual %|#<StandardError "boo">|
                  end

                  line do
                    plain "             not to match "
                    expected %|#<a kind of StandardError> with message "boo"|
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end
  end

  context "given only a simple RSpec fuzzy object and regexp message" do
    context "when used in the positive" do
      context "when the block raises a different error than what is given" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
                expect { raise StandardError.new('boo') }.to raise_error(a_kind_of(RuntimeError), /boo/i)
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet:
                  "expect { raise StandardError.new('boo') }.to raise_error(a_kind_of(RuntimeError), /boo/i)",
                newline_before_expectation: true,
                expectation:
                  proc do
                    line do
                      plain "Expected raised exception "
                      actual %|#<StandardError "boo">|
                    end

                    line do
                      plain "                 to match "
                      expected "#<a kind of RuntimeError> with message matching /boo/i"
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
      it "produces the correct failure message" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect { raise StandardError.new('boo') }.not_to raise_error(a_kind_of(StandardError), /boo/i)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect { raise StandardError.new('boo') }.not_to raise_error(a_kind_of(StandardError), /boo/i)",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "Expected raised exception "
                    actual %|#<StandardError "boo">|
                  end

                  line do
                    plain "             not to match "
                    expected "#<a kind of StandardError> with message matching /boo/i"
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end
  end

  # NOTE: No need to test this using a string or regexp message — we've tested
  # it enough above
  context "given a compound RSpec fuzzy object" do
    context "when used in the positive" do
      context "when the block raises a different error than what is given" do
        context "when the expected error and/or actual message is short" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                  expect { raise StandardError.new('boo') }.to raise_error(a_kind_of(Array).or eq(true))
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet:
                    "expect { raise StandardError.new('boo') }.to raise_error(a_kind_of(Array).or eq(true))",
                  expectation:
                    proc do
                      line do
                        plain "Expected raised exception "
                        actual %|#<StandardError "boo">|
                        plain " to match "
                        expected "#<a kind of Array or eq true>"
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

        context "when the expected error and/or actual message is long"
      end

      context "when the block raises no error" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expect { }.to raise_error(a_kind_of(RuntimeError).and having_attributes(beep: :boop))
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet:
                  "expect { }.to raise_error(a_kind_of(RuntimeError).and having_attributes(beep: :boop))",
                newline_before_expectation: true,
                expectation:
                  proc do
                    line do
                      plain "Expected "
                      actual "exception-free block"
                    end

                    line do
                      plain "to raise "
                      expected "#<a kind of RuntimeError and having attributes (beep: :boop)>"
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
      context "when the expected and/or actual message is short" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expect { raise StandardError.new('boo') }.not_to raise_error(a_kind_of(StandardError).or eq(true))
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet:
                  "expect { raise StandardError.new('boo') }.not_to raise_error(a_kind_of(StandardError).or eq(true))",
                expectation:
                  proc do
                    line do
                      plain "Expected raised exception "
                      actual %|#<StandardError "boo">|
                      plain " not to match "
                      expected "#<a kind of StandardError or eq true>"
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

      context "when the expected and/or actual message is long" do
        it "produces the correct failure message" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              expect { raise StandardError.new('this is a super super long message') }.not_to raise_error(a_kind_of(StandardError).and having_attributes(message: kind_of(String)))
            TEST
            program =
              make_plain_test_program(snippet, color_enabled: color_enabled)

            expected_output =
              build_expected_output(
                color_enabled: color_enabled,
                snippet:
                  "expect { raise StandardError.new('this is a super super long message') }.not_to raise_error(a_kind_of(StandardError).and having_attributes(message: kind_of(String)))",
                newline_before_expectation: true,
                expectation:
                  proc do
                    line do
                      plain "Expected raised exception "
                      actual %|#<StandardError "this is a super super long message">|
                    end

                    line do
                      plain "             not to match "
                      expected "#<a kind of StandardError and having attributes (message: #<a kind of String>)>"
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
