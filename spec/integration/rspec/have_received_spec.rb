require "spec_helper"

RSpec.describe "Integration with RSpec's #have_received matcher", type: :integration do
  # .to receive(...).with(any_args)
  # .to receive(...).with(no_args)
  # .to receive(...).with(...)
  # ^ any of that + .once or .twice or .times(...) or .never
  # and the method can be called never or with no args (expecting some args) or
  #   with different args (expecting no or some args)
  # or what happens if the method doesn't exist?
  # also, you can do all of this on an object that is either partially doubled,
  #   or a full double itself

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
              allow(object).to receive(:foo)
              expect(object).to have_received(:foo)
            TEST
            program = make_plain_test_program(
              snippet,
              color_enabled: color_enabled,
            )

            expected_output = build_expected_output(
              color_enabled: color_enabled,
              snippet: %|expect(object).to have_received(:foo)|,
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

    context "and matcher is qualified with .with" do
      # context "and any_args" do
      # end

      context "and no_args" do
        context "and the method is called with some arguments" do
          # this test is already done below
          xit "produces the correct output when used in the positive" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                class B
                  def foo; end
                end
                object = B.new
                allow(object).to receive(:foo)
                object.foo('bar', 'baz')
                expect(object).to have_received(:foo).with(no_args)
              TEST
              program = make_plain_test_program(
                snippet,
                color_enabled: color_enabled,
              )

              expected_output = build_expected_output(
                color_enabled: color_enabled,
                snippet: %|expect(object).to have_received(:foo).with(no_args)|,
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
          context "and the method is only called once" do
            it "produces the correct output when used in the positive" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  class B
                    def foo; end
                  end
                  object = B.new
                  allow(object).to receive(:foo)
                  object.foo('bar', 'baz')
                  expect(object).to have_received(:foo).with('qux')
                TEST
                program = make_plain_test_program(
                  snippet,
                  color_enabled: color_enabled,
                )

                expected_output = build_expected_output(
                  color_enabled: color_enabled,
                  snippet: %|expect(object).to have_received(:foo).with('qux')|,
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
                )

                expect(program).
                  to produce_output_when_run(expected_output).
                  removing_object_ids.
                  in_color(color_enabled)
              end
            end
          end

          context "and the method is called multiple times" do
            it "produces the correct output when used in the positive" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  class B
                    def foo; end
                  end
                  object = B.new
                  allow(object).to receive(:foo)
                  object.foo('bar', 'baz')
                  object.foo('qux', 'blargh')
                  expect(object).to have_received(:foo).with('qux')
                TEST
                program = make_plain_test_program(
                  snippet,
                  color_enabled: color_enabled,
                )

                expected_output = build_expected_output(
                  color_enabled: color_enabled,
                  snippet: %|expect(object).to have_received(:foo).with('qux')|,
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
                      plain " ("
                      beta "1"
                      plain " time)"
                    end

                    line indent_by: 2 do
                      plain "          "
                      beta %|("qux", "blargh")|
                      plain " ("
                      beta "1"
                      plain " time)"
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
        end

        context "and the method is called with the same arguments" do
          it "produces the correct output when used in the negative"
        end
      end
    end
  end
end
