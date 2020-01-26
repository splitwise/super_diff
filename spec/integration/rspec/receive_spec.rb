require "spec_helper"

# TODO: Should this reverse received vs. expected?
RSpec.describe "Integration with RSpec's #receive matcher", type: :integration do
  # with verifying doubles on vs. off
  # using: allow vs. expect
  # used against: a partially-doubled object vs. a double
  # method exists vs. doesn't exist
  # method is public vs. private or protected
  # qualified with:
  # - `with`
  #   * and any_args: no args in positive vs. any args in negative
  #   * and no_args: some args in positive vs. no args in negative
  #   * and some args: no args in positive vs. different args in positive vs.
  #     same args in negative
  # - `and_return`: different rv in positive vs. same rv in negative
  # - nothing: some args in positive vs. no args in negative
  #
  # with verifying doubles on:
  #
  # - what arguments was the matcher given?
  # - what arguments does the method take? -- if this is different from matcher
  #   then instafail
  # - what arguments was the method ultimately called with?

  context "with verifying doubles enabled" do
    around do |example|
      previous_verify_doubles =
        RSpec::Mocks.configuration.verify_partial_doubles?
      RSpec::Mocks.configuration.verify_partial_doubles = true

      example.run

      RSpec::Mocks.configuration.verify_partial_doubles =
        previous_verify_doubles
    end

    context "using allow" do
      context "when used in the positive" do
        context "when used against a partially-doubled object" do
          context "when the method exists" do
            context "and is public" do
              context "and the matcher is qualified with .with" do
                context "+ any_args" do
                  context "and the method takes no arguments" do
                    context "but the method is called with some arguments" do
                      it "raises an ArgumentError" do
                        as_both_colored_and_uncolored do |color_enabled|
                          snippet = <<~TEST.strip
                            class B
                              def foo; end
                            end
                            object = B.new
                            allow(object).to receive(:foo).with(any_args)
                            object.foo('bar', 'baz')
                          TEST
                          program = make_plain_test_program(
                            snippet,
                            color_enabled: color_enabled,
                          )

                          expected_output = build_expected_output(
                            color_enabled: color_enabled,
                            snippet: %|object.foo('bar', 'baz')|,
                            newline_before_expectation: true,
                            indentation: 5,
                            expectation: proc {
                              line do
                                red "ArgumentError:"
                              end

                              red_line indent_by: 2 do
                                text "Wrong number of arguments. "
                                text "Expected 0, got 2."
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

                  xcontext "and the method takes arguments" do
                    it "passes" do
                      as_both_colored_and_uncolored do |color_enabled|
                        snippet = <<~TEST.strip
                          class B
                            def foo(one, two); end
                          end
                          object = B.new
                          allow(object).to receive(:foo).with(any_args)
                        TEST
                        program = make_plain_test_program(
                          snippet,
                          color_enabled: color_enabled,
                        )

                        expected_output = build_expected_output(
                          color_enabled: color_enabled,
                          snippet: %|allow(object).to receive(:foo).any_args|,
                          expectation: proc {
                            red_line do
                              text "Wrong number of arguments. "
                              text "Expected 2, got 0."
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

                context "+ no_args" do
                  context "and the method takes no arguments" do
                    context "but the method is called with some arguments" do
                      it "raises an ArgumentError" do
                        as_both_colored_and_uncolored do |color_enabled|
                          snippet = <<~TEST.strip
                            class B
                              def foo; end
                            end
                            object = B.new
                            allow(object).to receive(:foo).with(no_args)
                            object.foo('bar', 'baz')
                          TEST
                          program = make_plain_test_program(
                            snippet,
                            color_enabled: color_enabled,
                          )

                          expected_output = build_expected_output(
                            color_enabled: color_enabled,
                            snippet: %|object.foo('bar', 'baz')|,
                            newline_before_expectation: true,
                            indentation: 5,
                            expectation: proc {
                              line do
                                red "ArgumentError:"
                              end

                              red_line indent_by: 2 do
                                text "Wrong number of arguments. "
                                text "Expected 0, got 2."
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

                  context "and the method takes arguments" do
                    it "raises an ArgumentError" do
                      as_both_colored_and_uncolored do |color_enabled|
                        snippet = <<~TEST.strip
                          class B
                            def foo(one, two); end
                          end
                          object = B.new
                          allow(object).to receive(:foo).with(no_args)
                        TEST
                        program = make_plain_test_program(
                          snippet,
                          color_enabled: color_enabled,
                        )

                        expected_output = build_expected_output(
                          color_enabled: color_enabled,
                          snippet: %|allow(object).to receive(:foo).with(no_args)|,
                          expectation: proc {
                            red_line do
                              text "Wrong number of arguments. "
                              text "Expected 2, got 0."
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

                context "+ some number of arguments" do
                  context "and the method takes no arguments" do
                    it "raises an ArgumentError" do
                      as_both_colored_and_uncolored do |color_enabled|
                        snippet = <<~TEST.strip
                          class B
                            def foo; end
                          end
                          object = B.new
                          allow(object).to receive(:foo).with('foo', 'bar')
                        TEST
                        program = make_plain_test_program(
                          snippet,
                          color_enabled: color_enabled,
                        )

                        expected_output = build_expected_output(
                          color_enabled: color_enabled,
                          snippet: %|allow(object).to receive(:foo).with('foo', 'bar')|,
                          expectation: proc {
                            red_line do
                              text "Wrong number of arguments. "
                              text "Expected 0, got 2."
                            end
                          },
                        )

                        expect(program).
                          to produce_output_when_run(expected_output).
                          in_color(color_enabled)
                      end
                    end
                  end

                  context "and the method takes some arguments" do
                    context "and is stubbed with a different number of arguments"
                  end

                  context "and the method takes a different number of arguments" do
                    it "raises an ArgumentError" do
                      as_both_colored_and_uncolored do |color_enabled|
                        snippet = <<~TEST.strip
                          class B
                            def foo(arg); end
                          end
                          object = B.new
                          allow(object).to receive(:foo).with('foo', 'bar')
                        TEST
                        program = make_plain_test_program(
                          snippet,
                          color_enabled: color_enabled,
                        )

                        expected_output = build_expected_output(
                          color_enabled: color_enabled,
                          snippet: %|allow(object).to receive(:foo).with('foo', 'bar')|,
                          expectation: proc {
                            red_line do
                              text "Wrong number of arguments. "
                              text "Expected 1, got 2."
                            end
                          },
                        )

                        expect(program).
                          to produce_output_when_run(expected_output).
                          in_color(color_enabled)
                      end
                    end
                  end

                  context "and the method takes arguments" do
                    context "and the method is called with the same number of arguments, but different values" do
                      it "fails with the correct output" do
                        as_both_colored_and_uncolored do |color_enabled|
                          snippet = <<~TEST.strip
                            class B
                              def foo(one, two); end
                            end
                            object = B.new
                            allow(object).to receive(:foo).with('foo', 'bar')
                            object.foo('baz', 'qux')
                          TEST
                          program = make_plain_test_program(
                            snippet,
                            color_enabled: color_enabled,
                          )

                          expected_output = build_expected_output(
                            color_enabled: color_enabled,
                            snippet: %|object.foo('baz', 'qux')|,
                            newline_before_expectation: true,
                            expectation: proc {
                              red_line(
                                "#<B> received #foo with unexpected arguments.",
                              )

                              newline

                              line do
                                plain "Expected: "
                                alpha %|("foo", "bar")|
                              end

                              line do
                                plain "     Got: "
                                beta %|("baz", "qux")|
                              end
                            },
                            diff: proc {
                              plain_line %!  [!
                              alpha_line %!-   "foo",!
                              beta_line  %!+   "baz",!
                              alpha_line %!-   "bar"!
                              beta_line  %!+   "qux"!
                              plain_line %!  ]!
                            },
                          )

                          expect(program).
                            to produce_output_when_run(expected_output).
                            removing_object_ids.
                            in_color(color_enabled)
                        end
                      end
                    end

                    context "and the method is called with a different number of arguments" do
                      it "raises an ArgumentError" do
                        as_both_colored_and_uncolored do |color_enabled|
                          snippet = <<~TEST.strip
                            class B
                              def foo(one); end
                            end
                            object = B.new
                            allow(object).to receive(:foo).with('foo', 'bar')
                            object.foo('baz', 'qux')
                          TEST
                          program = make_plain_test_program(
                            snippet,
                            color_enabled: color_enabled,
                          )

                          expected_output = build_expected_output(
                            color_enabled: color_enabled,
                            snippet: %|allow(object).to receive(:foo).with('foo', 'bar')|,
                            expectation: proc {
                              red_line do
                                text "Wrong number of arguments. "
                                text "Expected 1, got 2."
                              end
                            },
                          )

                          expect(program).
                            to produce_output_when_run(expected_output).
                            removing_object_ids.
                            in_color(color_enabled)
                        end
                      end
                    end

                    context "and the method is called with no arguments altogether"

                    context "and the method is called with the same arguments"
                  end
                end
              end
            end

            context "and it is protected"

            context "and it is private"
          end

          context "when the method does not exist"
        end

        context "when used against a double"
      end

      context "when used in the negative" do
        it "fails with the correct output" do
          as_both_colored_and_uncolored do |color_enabled|
            snippet = <<~TEST.strip
              allow(Object.new).not_to receive(:foo)
            TEST
            program = make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
            )

            expected_output = build_expected_output(
              color_enabled: color_enabled,
              snippet: %|allow(Object.new).not_to receive(:foo)|,
              expectation: proc {
                red_line(
                  "`allow(...).not_to receive` is not supported since it " +
                  "doesn't really make sense. What would it even mean?",
                )
              },
            )

            expect(program).
              to produce_output_when_run(expected_output).
              in_color(color_enabled)
          end
        end
      end
    end

=begin
    context "using expect" do
      context "when used against a partially-doubled object" do
        context "and the matcher is not qualified with anything" do
          context "and the method does not exist" do
            it "produces the correct output when used in the positive" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  class B; end
                  object = B.new
                  expect(object).to receive(:foo)
                TEST

                program = make_plain_test_program(
                  snippet,
                  color_enabled: color_enabled,
                )

                expected_output = build_expected_output(
                  color_enabled: color_enabled,
                  snippet: %|expect(object).to receive(:foo)|,
                  newline_before_expectation: true,
                  expectation: proc {
                    line do
                      red "Could not place double."
                    end

                    newline

                    line do
                      blue "foo"
                      plain " is not a method on "
                      yellow "#<B>"
                      plain "."
                    end
                  },
                )

                expect(program).
                  to produce_output_when_run(expected_output).
                  removing_object_ids.
                  in_color(color_enabled)
              end
            end

            it "produces the correct output when used in the negative???"
          end

          context "and the method is never called" do
            it "produces the correct output when used in the positive" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  class B
                    def foo; end
                  end
                  object = B.new
                  expect(object).to receive(:foo)
                TEST
                program = make_plain_test_program(
                  snippet,
                  color_enabled: color_enabled,
                )

                expected_output = build_expected_output(
                  color_enabled: color_enabled,
                  snippet: %|expect(object).to receive(:foo)|,
                  newline_before_expectation: true,
                  expectation: proc {
                    line do
                      red "Expectation failed for double: B#foo"
                    end

                    line indent_by: 2 do
                      plain "Expected: "
                      alpha "1"
                      plain " time with "
                      alpha "any"
                      plain " arguments"
                    end

                    line indent_by: 2 do
                      plain "Received: "
                      beta "0"
                      plain " times"
                    end
                  },
                )

                expect(program).
                  to produce_output_when_run(expected_output).
                  removing_object_ids.
                  in_color(color_enabled)
              end
            end

            it "produces the correct output when used in the negative???"
          end

          context "and the method is called" do
            it "produces the correct output when used in the negative"
          end
        end
      end
    end
=end
  end
end
