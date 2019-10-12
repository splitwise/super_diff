require "spec_helper"

RSpec.describe "Integration with RSpec's #have_received matcher", type: :integration do
  # .to receive(...).with(any_args)
  # .to receive(...).with(no_args)
  # .to receive(...).with(...)
  # ^ any of that + .once or .twice or .times(...) or .never
  # and the method can be called never or with no args (expecting some args) or with different args (expecting no or some args)
  # or what happens if the method doesn't exist?
  # also, you can do all of this on an object that is either partially doubled, or a full double itself

  context "when the object has been partially doubled" do
    context "and no expectations on arguments are made" do
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
                  plain "(#<B>).foo(*(any args))"
                end

                line do
                  plain "  expected: "
                  beta "1"
                  plain " time with "
                  beta "any"
                  plain " arguments"
                end

                line do
                  plain "  received: "
                  alpha "0"
                  plain " times with "
                  alpha "any"
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

      context "and the method is called"
    end

    context "and expectations on arguments are made" do
      context "using any_args"

      context "using no_args"

      context "using a variable number of arguments" do
        context "and the method is called, but with different arguments" do
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
                snippet: %|expect(object).to have_received(:foo)|,
                newline_before_expectation: true,
                expectation: proc {
                  line do
                    plain "(#<B>).foo(*(any args))"
                  end

                  line do
                    plain "  expected: "
                    beta "1"
                    plain " time with "
                    beta "any"
                    plain " arguments"
                  end

                  line do
                    plain "  received: "
                    alpha "0"
                    plain " times with "
                    alpha "any"
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
      end
    end
  end
end
