require "spec_helper"

RSpec.describe "Integration with RSpec's #receive matcher", type: :integration do
  context "using allow" do
    context "when used against a partially-doubled object" do
      context "and matcher is qualified with .with" do
        # context "and any_args" do
        # end

        context "and no_args" do
          context "and the method is called with some arguments" do
            it "produces the correct output when used in the positive" do
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
                  snippet: %|expect(object).to receive(:foo).with(no_args)|,
                  newline_before_expectation: true,
                  expectation: proc {
                    line do
                      highlight "#<B>"
                      plain " received "
                      highlight ":foo"
                      plain " with unexpected arguments"
                    end

                    line indent_by: 2 do
                      plain "expected: "
                      alpha %|(no args)|
                    end

                    line indent_by: 2 do
                      plain "     got: "
                      beta %|("bar", "baz")|
                    end
                  },
                  diff: proc {
                    plain_line %!  [!
                    alpha_line %!-   "qux"!
                    beta_line  %!+   "bar",!
                    beta_line  %!+   "baz"!
                    plain_line %!  ]!
                  },
                  after_diff: (
                    "Please stub a default value first if message might be " +
                    "received with other args as well."
                  ),
                )

                expect(program).
                  to produce_output_when_run(expected_output).
                  removing_object_ids.
                  in_color(color_enabled)
              end
            end
          end

          context "and the method is called with no arguments" do
            it "produces the correct output when used in the negative"
          end
        end

        context "and some number of arguments" do
          context "and the method is called with no arguments"

          context "and the method is called with different arguments" do
            it "produces the correct output when used in the positive" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  class B
                    def foo; end
                  end
                  object = B.new
                  expect(object).to receive(:foo).with('qux')
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
                  expectation: proc {
                    line do
                      highlight "#<B>"
                      plain " received "
                      highlight ":foo"
                      plain " with unexpected arguments"
                    end

                    line indent_by: 2 do
                      plain "expected: "
                      alpha %|("qux")|
                    end

                    line indent_by: 2 do
                      plain "     got: "
                      beta %|("bar", "baz")|
                    end
                  },
                  diff: proc {
                    plain_line %!  [!
                    alpha_line %!-   "qux"!
                    beta_line  %!+   "bar",!
                    beta_line  %!+   "baz"!
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

          context "and the method is called with the same arguments" do
            it "produces the correct output when used in the negative"
          end
        end
      end
    end
  end

  context "using expect" do
    context "when used against a partially-doubled object" do
      context "and the matcher is not qualified with anything" do
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
                    highlight "(#<B>).foo(*(any args))"
                  end

                  line indent_by: 2 do
                    plain "expected: "
                    alpha "1"
                    plain " time with "
                    alpha "any"
                    plain " arguments"
                  end

                  line indent_by: 2 do
                    plain "received: "
                    beta "0"
                    plain " times with "
                    beta "any"
                    plain " arguments"
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

        context "and the method is called" do
          it "produces the correct output when used in the negative"
        end
      end
    end
  end
end
