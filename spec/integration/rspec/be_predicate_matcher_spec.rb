require "spec_helper"

RSpec.describe "Integration with RSpec's #be_* matcher", type: :integration do
  # rubocop:disable Metrics/BlockLength
  ["be", "be_a", "be_an"].each do |prefix|
  # rubocop:enable Metrics/BlockLength
    context "using #{prefix}_<predicate>" do
      context "when the predicate method doesn't exist on the object" do
        context "when the inspected version of the actual value is short" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = %|expect(:foo).to #{prefix}_strong|
              program = make_plain_test_program(
                snippet,
                color_enabled: color_enabled,
              )

              expected_output = build_expected_output(
                color_enabled: color_enabled,
                snippet: snippet,
                expectation: proc {
                  line do
                    plain "Expected "
                    beta %|:foo|
                    plain " to respond to "
                    alpha %|`strong?`|
                    plain " or "
                    alpha %|`strongs?`|
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

        context "when the inspected version of the actual value is long" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                hash = { foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz" }
                expect(hash).to #{prefix}_strong
              TEST
              program = make_plain_test_program(
                snippet,
                color_enabled: color_enabled,
              )

              expected_output = build_expected_output(
                color_enabled: color_enabled,
                snippet: %|expect(hash).to #{prefix}_strong|,
                newline_before_expectation: true,
                expectation: proc {
                  line do
                    plain "     Expected "
                    beta %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz" }|
                  end

                  line do
                    plain "to respond to "
                    alpha %|`strong?`|
                    plain " or "
                    alpha %|`strongs?`|
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

      context "when the predicate method exists on the object" do
        context "but is private" do
          context "when the inspected version of the actual value is short" do
            it "produces the correct failure message" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  class Foo
                    private def strong?; end
                  end

                  expect(Foo.new).to #{prefix}_strong
                TEST
                program = make_plain_test_program(
                  snippet,
                  color_enabled: color_enabled,
                )

                expected_output = build_expected_output(
                  color_enabled: color_enabled,
                  snippet: %|expect(Foo.new).to #{prefix}_strong|,
                  expectation: proc {
                    line do
                      plain "Expected "
                      beta %|#<Foo>|
                      plain " to have a public method "
                      alpha %|`strong?`|
                      plain " or "
                      alpha %|`strongs?`|
                      plain "."
                    end
                  },
                )

                expect(program).
                  to produce_output_when_run(expected_output).
                  in_color(color_enabled).
                  removing_object_ids
              end
            end
          end

          context "when the inspected version of the actual value is long" do
            it "produces the correct failure message" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  hash = { foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz" }

                  class << hash
                    private def strong?; end
                  end

                  expect(hash).to #{prefix}_strong
                TEST
                program = make_plain_test_program(
                  snippet,
                  color_enabled: color_enabled,
                )

                expected_output = build_expected_output(
                  color_enabled: color_enabled,
                  snippet: %|expect(hash).to #{prefix}_strong|,
                  newline_before_expectation: true,
                  expectation: proc {
                    line do
                      plain "               Expected "
                      beta %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz" }|
                    end

                    line do
                      plain "to have a public method "
                      alpha %|`strong?`|
                      plain " or "
                      alpha %|`strongs?`|
                    end
                  },
                )

                expect(program).
                  to produce_output_when_run(expected_output).
                  in_color(color_enabled).
                  removing_object_ids
              end
            end
          end
        end

        context "and is public" do
          context "and returns false" do
            context "but is called #true?" do
              context "when the inspected version of the actual value is short" do
                it "produces the correct failure message" do
                  as_both_colored_and_uncolored do |color_enabled|
                    snippet = <<~TEST.strip
                      class Foo
                        def true?; false; end
                      end

                      expect(Foo.new).to #{prefix}_true
                    TEST
                    program = make_plain_test_program(
                      snippet,
                      color_enabled: color_enabled,
                    )

                    expected_output = build_expected_output(
                      color_enabled: color_enabled,
                      snippet: %|expect(Foo.new).to #{prefix}_true|,
                      newline_before_expectation: true,
                      expectation: proc {
                        line do
                          plain "Expected "
                          beta %|#<Foo>|
                          plain " to return a truthy result for "
                          alpha %|`true?`|
                          plain " or "
                          alpha %|`trues?`|
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
                      in_color(color_enabled).
                      removing_object_ids
                  end
                end
              end

              context "when the inspected version of the actual value is long" do
                it "produces the correct failure message" do
                  as_both_colored_and_uncolored do |color_enabled|
                    snippet = <<~TEST.strip
                      hash = {
                        foo: "bar",
                        baz: "qux",
                        blargh: "foz",
                        fizz: "buzz"
                      }

                      class << hash
                        def true?; false; end
                      end

                      expect(hash).to #{prefix}_true
                    TEST
                    program = make_plain_test_program(
                      snippet,
                      color_enabled: color_enabled,
                    )

                    expected_output = build_expected_output(
                      color_enabled: color_enabled,
                      snippet: %|expect(hash).to #{prefix}_true|,
                      newline_before_expectation: true,
                      expectation: proc {
                        line do
                          plain "                     Expected "
                          beta %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz" }|
                        end

                        line do
                          plain "to return a truthy result for "
                          alpha %|`true?`|
                          plain " or "
                          alpha %|`trues?`|
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
                      in_color(color_enabled).
                      removing_object_ids
                  end
                end
              end
            end

            context "but is called #false?" do
              it "produces the correct failure message" do
                as_both_colored_and_uncolored do |color_enabled|
                  snippet = <<~TEST.strip
                    class X
                      def false?; false; end
                    end

                    expect(X.new).to #{prefix}_false
                  TEST
                  program = make_plain_test_program(
                    snippet,
                    color_enabled: color_enabled,
                  )

                  expected_output = build_expected_output(
                    color_enabled: color_enabled,
                    snippet: %|expect(X.new).to #{prefix}_false|,
                    newline_before_expectation: true,
                    expectation: proc {
                      line do
                        plain "Expected "
                        beta %|#<X>|
                        plain " to return a truthy result for "
                        alpha %|`false?`|
                        plain " or "
                        alpha %|`falses?`|
                        plain "."
                      end
                    },
                  )

                  expect(program).
                    to produce_output_when_run(expected_output).
                    in_color(color_enabled).
                    removing_object_ids
                end
              end
            end

            context "and is called neither #true? nor #false?" do
              context "and is singular" do
                context "when the inspected version of the actual value is short" do
                  it "produces the correct failure message" do
                    as_both_colored_and_uncolored do |color_enabled|
                      snippet = <<~TEST.strip
                        class X
                          def y?; false; end
                        end

                        expect(X.new).to #{prefix}_y
                      TEST
                      program = make_plain_test_program(
                        snippet,
                        color_enabled: color_enabled,
                      )

                      expected_output = build_expected_output(
                        color_enabled: color_enabled,
                        snippet: %|expect(X.new).to #{prefix}_y|,
                        expectation: proc {
                          line do
                            plain "Expected "
                            beta %|#<X>|
                            plain " to return a truthy result for "
                            alpha %|`y?`|
                            plain " or "
                            alpha %|`ys?`|
                            plain "."
                          end
                        },
                      )

                      expect(program).
                        to produce_output_when_run(expected_output).
                        in_color(color_enabled).
                        removing_object_ids
                    end
                  end
                end

                context "when the inspected version of the actual value is long" do
                  it "produces the correct failure message" do
                    as_both_colored_and_uncolored do |color_enabled|
                      snippet = <<~TEST.strip
                        hash = {
                          foo: "bar",
                          baz: "qux",
                          blargh: "foz",
                          fizz: "buzz",
                          aaaaaa: "bbbbbb"
                        }

                        class << hash
                          def y?; false; end
                        end

                        expect(hash).to #{prefix}_y
                      TEST
                      program = make_plain_test_program(
                        snippet,
                        color_enabled: color_enabled,
                      )

                      expected_output = build_expected_output(
                        color_enabled: color_enabled,
                        snippet: %|expect(hash).to #{prefix}_y|,
                        newline_before_expectation: true,
                        expectation: proc {
                          line do
                            plain "                     Expected "
                            beta %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz", aaaaaa: "bbbbbb" }|
                          end

                          line do
                            plain "to return a truthy result for "
                            alpha %|`y?`|
                            plain " or "
                            alpha %|`ys?`|
                          end
                        },
                      )

                      expect(program).
                        to produce_output_when_run(expected_output).
                        in_color(color_enabled).
                        removing_object_ids
                    end
                  end
                end
              end

              context "and is plural" do
                context "when the inspected version of the actual value is short" do
                  it "produces the correct failure message" do
                    as_both_colored_and_uncolored do |color_enabled|
                      snippet = <<~TEST.strip
                        class X
                          def ys?; false; end
                        end

                        expect(X.new).to #{prefix}_y
                      TEST
                      program = make_plain_test_program(
                        snippet,
                        color_enabled: color_enabled,
                      )

                      expected_output = build_expected_output(
                        color_enabled: color_enabled,
                        snippet: %|expect(X.new).to #{prefix}_y|,
                        expectation: proc {
                          line do
                            plain "Expected "
                            beta %|#<X>|
                            plain " to return a truthy result for "
                            alpha %|`y?`|
                            plain " or "
                            alpha %|`ys?`|
                            plain "."
                          end
                        },
                      )

                      expect(program).
                        to produce_output_when_run(expected_output).
                        in_color(color_enabled).
                        removing_object_ids
                    end
                  end
                end

                context "when the inspected version of the actual value is long" do
                  it "produces the correct failure message" do
                    as_both_colored_and_uncolored do |color_enabled|
                      snippet = <<~TEST.strip
                        hash = {
                          foo: "bar",
                          baz: "qux",
                          blargh: "foz",
                          fizz: "buzz",
                          aaaaaa: "bbbbbb"
                        }

                        class << hash
                          def ys?; false; end
                        end

                        expect(hash).to #{prefix}_y
                      TEST
                      program = make_plain_test_program(
                        snippet,
                        color_enabled: color_enabled,
                      )

                      expected_output = build_expected_output(
                        color_enabled: color_enabled,
                        snippet: %|expect(hash).to #{prefix}_y|,
                        newline_before_expectation: true,
                        expectation: proc {
                          line do
                            plain "                     Expected "
                            beta %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz", aaaaaa: "bbbbbb" }|
                          end

                          line do
                            plain "to return a truthy result for "
                            alpha %|`y?`|
                            plain " or "
                            alpha %|`ys?`|
                          end
                        },
                      )

                      expect(program).
                        to produce_output_when_run(expected_output).
                        in_color(color_enabled).
                        removing_object_ids
                    end
                  end
                end
              end
            end
          end

          context "and returns true" do
            it "produces the correct failure message when used in the negative" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  class Foo
                    def strong?; true; end
                  end

                  expect(Foo.new).not_to #{prefix}_strong
                TEST
                program = make_plain_test_program(
                  snippet,
                  color_enabled: color_enabled,
                )

                expected_output = build_expected_output(
                  color_enabled: color_enabled,
                  snippet: %|expect(Foo.new).not_to #{prefix}_strong|,
                  expectation: proc {
                    line do
                      plain "Expected "
                      beta %|#<Foo>|
                      plain " not to return a truthy result for "
                      alpha %|`strong?`|
                      plain " or "
                      alpha %|`strongs?`|
                      plain "."
                    end
                  },
                )

                expect(program).
                  to produce_output_when_run(expected_output).
                  in_color(color_enabled).
                  removing_object_ids
              end
            end
          end
        end
      end
    end
  end
end
