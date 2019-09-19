require "spec_helper"

RSpec.describe "Integration with RSpec's #be_* matcher", type: :integration do
  context "assuming color is enabled" do
    ["be", "be_a", "be_an"].each do |prefix|
      context "using #{prefix}_<predicate>" do
        context "when the predicate method doesn't exist on the object" do
          context "when the inspected version of the actual value is short" do
            it "produces the correct output" do
              program = make_plain_test_program(<<~TEST.strip)
                expect(:foo).to #{prefix}_strong
              TEST

              expected_output = build_colored_expected_output(
                snippet: %|expect(:foo).to #{prefix}_strong|,
                expectation: proc {
                  line do
                    plain "Expected "
                    yellow %|:foo|
                    plain " to respond to "
                    magenta %|`strong?`|
                    plain " or "
                    magenta %|`strongs?`|
                    plain "."
                  end
                },
              )

              expect(program).to produce_output_when_run(expected_output)
            end
          end

          context "when the inspected version of the actual value is long" do
            it "produces the correct output" do
              program = make_plain_test_program(<<~TEST.strip)
                hash = { foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz" }
                expect(hash).to #{prefix}_strong
              TEST

              expected_output = build_colored_expected_output(
                snippet: %|expect(hash).to #{prefix}_strong|,
                newline_before_expectation: true,
                expectation: proc {
                  line do
                    plain "     Expected "
                    yellow %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz" }|
                  end

                  line do
                    plain "to respond to "
                    magenta %|`strong?`|
                    plain " or "
                    magenta %|`strongs?`|
                  end
                },
              )

              expect(program).to produce_output_when_run(expected_output)
            end
          end
        end

        context "when the predicate method exists on the object" do
          context "but is private" do
            context "when the inspected version of the actual value is short" do
              it "produces the correct output" do
                program = make_plain_test_program(<<~TEST.strip)
                  class Foo
                    private def strong?; end
                  end

                  expect(Foo.new).to #{prefix}_strong
                TEST

                expected_output = build_colored_expected_output(
                  snippet: %|expect(Foo.new).to #{prefix}_strong|,
                  expectation: proc {
                    line do
                      plain "Expected "
                      yellow %|#<Foo>|
                      plain " to have a public method "
                      magenta %|`strong?`|
                      plain " or "
                      magenta %|`strongs?`|
                      plain "."
                    end
                  },
                )

                expect(program).
                  to produce_output_when_run(expected_output).
                  removing_object_ids
              end
            end

            context "when the inspected version of the actual value is long" do
              it "produces the correct output" do
                program = make_plain_test_program(<<~TEST.strip)
                  hash = { foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz" }

                  class << hash
                    private def strong?; end
                  end

                  expect(hash).to #{prefix}_strong
                TEST

                expected_output = build_colored_expected_output(
                  snippet: %|expect(hash).to #{prefix}_strong|,
                  newline_before_expectation: true,
                  expectation: proc {
                    line do
                      plain "               Expected "
                      yellow %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz" }|
                    end

                    line do
                      plain "to have a public method "
                      magenta %|`strong?`|
                      plain " or "
                      magenta %|`strongs?`|
                    end
                  },
                )

                expect(program).
                  to produce_output_when_run(expected_output).
                  removing_object_ids
              end
            end
          end

          context "and is public and returns false" do
            context "but is called #true?" do
              context "when the inspected version of the actual value is short" do
                it "produces the correct output" do
                  program = make_plain_test_program(<<~TEST.strip)
                    class Foo
                      def true?; false; end
                    end

                    expect(Foo.new).to #{prefix}_true
                  TEST

                  expected_output = build_colored_expected_output(
                    snippet: %|expect(Foo.new).to #{prefix}_true|,
                    newline_before_expectation: true,
                    expectation: proc {
                      line do
                        plain "Expected "
                        yellow %|#<Foo>|
                        plain " to return true for "
                        magenta %|`true?`|
                        plain " or "
                        magenta %|`trues?`|
                        plain "."
                      end

                      newline

                      line do
                        plain "(Perhaps you want to use "
                        blue "`be(true)`"
                        plain " or "
                        blue "`be_truthy`"
                        plain " instead?)"
                      end
                    },
                  )

                  expect(program).
                    to produce_output_when_run(expected_output).
                    removing_object_ids
                end
              end

              context "when the inspected version of the actual value is long" do
                it "produces the correct output" do
                  program = make_plain_test_program(<<~TEST.strip)
                    hash = { foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz" }

                    class << hash
                      def true?; false; end
                    end

                    expect(hash).to #{prefix}_true
                  TEST

                  expected_output = build_colored_expected_output(
                    snippet: %|expect(hash).to #{prefix}_true|,
                    newline_before_expectation: true,
                    expectation: proc {
                      line do
                        plain "          Expected "
                        yellow %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz" }|
                      end

                      line do
                        plain "to return true for "
                        magenta %|`true?`|
                        plain " or "
                        magenta %|`trues?`|
                      end

                      newline

                      line do
                        plain "(Perhaps you want to use "
                        blue "`be(true)`"
                        plain " or "
                        blue "`be_truthy`"
                        plain " instead?)"
                      end
                    },
                  )

                  expect(program).
                    to produce_output_when_run(expected_output).
                    removing_object_ids
                end
              end
            end

            context "but is called #false?" do
              it "produces the correct output" do
                program = make_plain_test_program(<<~TEST.strip)
                  class X
                    def false?; false; end
                  end

                  expect(X.new).to #{prefix}_false
                TEST

                expected_output = build_colored_expected_output(
                  snippet: %|expect(X.new).to #{prefix}_false|,
                  newline_before_expectation: true,
                  expectation: proc {
                    line do
                      plain "Expected "
                      yellow %|#<X>|
                      plain " to return true for "
                      magenta %|`false?`|
                      plain " or "
                      magenta %|`falses?`|
                      plain "."
                    end
                  },
                )

                expect(program).
                  to produce_output_when_run(expected_output).
                  removing_object_ids
              end
            end

            context "and is called neither #true? nor #false?" do
              context "and is singular" do
                context "when the inspected version of the actual value is short" do
                  it "produces the correct output" do
                    program = make_plain_test_program(<<~TEST.strip)
                      class X
                        def y?; false; end
                      end

                      expect(X.new).to #{prefix}_y
                    TEST

                    expected_output = build_colored_expected_output(
                      snippet: %|expect(X.new).to #{prefix}_y|,
                      expectation: proc {
                        line do
                          plain "Expected "
                          yellow %|#<X>|
                          plain " to return true for "
                          magenta %|`y?`|
                          plain " or "
                          magenta %|`ys?`|
                          plain "."
                        end
                      },
                    )

                    expect(program).
                      to produce_output_when_run(expected_output).
                      removing_object_ids
                  end
                end

                context "when the inspected version of the actual value is long" do
                  it "produces the correct output" do
                    program = make_plain_test_program(<<~TEST.strip)
                      hash = { foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz", aaaaaa: "bbbbbb" }

                      class << hash
                        def y?; false; end
                      end

                      expect(hash).to #{prefix}_y
                    TEST

                    expected_output = build_colored_expected_output(
                      snippet: %|expect(hash).to #{prefix}_y|,
                      newline_before_expectation: true,
                      expectation: proc {
                        line do
                          plain "          Expected "
                          yellow %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz", aaaaaa: "bbbbbb" }|
                        end

                        line do
                          plain "to return true for "
                          magenta %|`y?`|
                          plain " or "
                          magenta %|`ys?`|
                        end
                      },
                    )

                    expect(program).
                      to produce_output_when_run(expected_output).
                      removing_object_ids
                  end
                end
              end

              context "and is plural" do
                context "when the inspected version of the actual value is short" do
                  it "produces the correct output" do
                    program = make_plain_test_program(<<~TEST.strip)
                      class X
                        def ys?; false; end
                      end

                      expect(X.new).to #{prefix}_y
                    TEST

                    expected_output = build_colored_expected_output(
                      snippet: %|expect(X.new).to #{prefix}_y|,
                      expectation: proc {
                        line do
                          plain "Expected "
                          yellow %|#<X>|
                          plain " to return true for "
                          magenta %|`y?`|
                          plain " or "
                          magenta %|`ys?`|
                          plain "."
                        end
                      },
                    )

                    expect(program).
                      to produce_output_when_run(expected_output).
                      removing_object_ids
                  end
                end

                context "when the inspected version of the actual value is long" do
                  it "produces the correct output" do
                    program = make_plain_test_program(<<~TEST.strip)
                      hash = { foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz", aaaaaa: "bbbbbb" }

                      class << hash
                        def ys?; false; end
                      end

                      expect(hash).to #{prefix}_y
                    TEST

                    expected_output = build_colored_expected_output(
                      snippet: %|expect(hash).to #{prefix}_y|,
                      newline_before_expectation: true,
                      expectation: proc {
                        line do
                          plain "          Expected "
                          yellow %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz", aaaaaa: "bbbbbb" }|
                        end

                        line do
                          plain "to return true for "
                          magenta %|`y?`|
                          plain " or "
                          magenta %|`ys?`|
                        end
                      },
                    )

                    expect(program).
                      to produce_output_when_run(expected_output).
                      removing_object_ids
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
