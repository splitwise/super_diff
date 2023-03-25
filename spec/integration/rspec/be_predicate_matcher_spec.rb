require "spec_helper"

RSpec.describe "Integration with RSpec's #be_<predicate> matcher",
               type: :integration do
  # rubocop:disable Metrics/BlockLength
  %w[be be_a be_an].each do |prefix|
    # rubocop:enable Metrics/BlockLength
    context "using #{prefix}_<predicate>" do
      context "when the predicate method doesn't exist on the object" do
        context "when the inspected version of the actual   value is short" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = %|expect(:foo).to #{prefix}_strong|
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet: snippet,
                  expectation:
                    proc do
                      line do
                        plain "Expected "
                        actual ":foo"
                        plain " to respond to "
                        expected "strong?"
                        plain " or "
                        expected "strongs?"
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

        context "when the inspected version of the actual   value is long" do
          it "produces the correct failure message" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                hash = { foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz", aaaaaa: "bbbbbb" }
                expect(hash).to #{prefix}_strong
              TEST
              program =
                make_plain_test_program(snippet, color_enabled: color_enabled)

              expected_output =
                build_expected_output(
                  color_enabled: color_enabled,
                  snippet: %|expect(hash).to #{prefix}_strong|,
                  newline_before_expectation: true,
                  expectation:
                    proc do
                      line do
                        plain "     Expected "
                        actual %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz", aaaaaa: "bbbbbb" }|
                      end

                      line do
                        plain "to respond to "
                        expected "strong?"
                        plain " or "
                        expected "strongs?"
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

      context "when the predicate method exists on the object" do
        context "but is private" do
          context "when the inspected version of the actual   value is short" do
            it "produces the correct failure message" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  class Foo
                    private def strong?; end
                  end

                  expect(Foo.new).to #{prefix}_strong
                TEST
                program =
                  make_plain_test_program(snippet, color_enabled: color_enabled)

                expected_output =
                  build_expected_output(
                    color_enabled: color_enabled,
                    snippet: %|expect(Foo.new).to #{prefix}_strong|,
                    expectation:
                      proc do
                        line do
                          plain "Expected "
                          actual "#<Foo>"
                          plain " to have a public method "
                          expected "strong?"
                          plain " or "
                          expected "strongs?"
                          plain "."
                        end
                      end
                  )

                expect(program).to produce_output_when_run(
                  expected_output
                ).in_color(color_enabled).removing_object_ids
              end
            end
          end

          context "when the inspected version of the actual   value is long" do
            it "produces the correct failure message" do
              as_both_colored_and_uncolored do |color_enabled|
                snippet = <<~TEST.strip
                  hash = { foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz" }

                  class << hash
                    private def strong?; end
                  end

                  expect(hash).to #{prefix}_strong
                TEST
                program =
                  make_plain_test_program(snippet, color_enabled: color_enabled)

                expected_output =
                  build_expected_output(
                    color_enabled: color_enabled,
                    snippet: %|expect(hash).to #{prefix}_strong|,
                    newline_before_expectation: true,
                    expectation:
                      proc do
                        line do
                          plain "               Expected "
                          actual %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz" }|
                        end

                        line do
                          plain "to have a public method "
                          expected "strong?"
                          plain " or "
                          expected "strongs?"
                        end
                      end
                  )

                expect(program).to produce_output_when_run(
                  expected_output
                ).in_color(color_enabled).removing_object_ids
              end
            end
          end
        end

        context "and is public" do
          context "and returns false" do
            context "but is called #true?" do
              context "when the inspected version of the actual   value is short" do
                it "produces the correct failure message" do
                  as_both_colored_and_uncolored do |color_enabled|
                    snippet = <<~TEST.strip
                      class Foo
                        def true?; false; end
                      end

                      expect(Foo.new).to #{prefix}_true
                    TEST
                    program =
                      make_plain_test_program(
                        snippet,
                        color_enabled: color_enabled
                      )

                    expected_output =
                      build_expected_output(
                        color_enabled: color_enabled,
                        snippet: %|expect(Foo.new).to #{prefix}_true|,
                        newline_before_expectation: true,
                        expectation:
                          proc do
                            line do
                              plain "Expected "
                              actual "#<Foo>"
                              plain " to return a truthy result for "
                              expected "true?"
                              plain " or "
                              expected "trues?"
                              plain "."
                            end

                            newline

                            line do
                              plain "(Perhaps you want to use "
                              blue "be(true)"
                              plain " or "
                              blue "be_truthy"
                              plain " instead?)"
                            end
                          end
                      )

                    expect(program).to produce_output_when_run(
                      expected_output
                    ).in_color(color_enabled).removing_object_ids
                  end
                end
              end

              context "when the inspected version of the actual   value is long" do
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
                    program =
                      make_plain_test_program(
                        snippet,
                        color_enabled: color_enabled
                      )

                    expected_output =
                      build_expected_output(
                        color_enabled: color_enabled,
                        snippet: %|expect(hash).to #{prefix}_true|,
                        newline_before_expectation: true,
                        expectation:
                          proc do
                            line do
                              plain "                     Expected "
                              actual %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz" }|
                            end

                            line do
                              plain "to return a truthy result for "
                              expected "true?"
                              plain " or "
                              expected "trues?"
                            end

                            newline

                            line do
                              plain "(Perhaps you want to use "
                              blue "be(true)"
                              plain " or "
                              blue "be_truthy"
                              plain " instead?)"
                            end
                          end
                      )

                    expect(program).to produce_output_when_run(
                      expected_output
                    ).in_color(color_enabled).removing_object_ids
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
                  program =
                    make_plain_test_program(
                      snippet,
                      color_enabled: color_enabled
                    )

                  expected_output =
                    build_expected_output(
                      color_enabled: color_enabled,
                      snippet: %|expect(X.new).to #{prefix}_false|,
                      newline_before_expectation: true,
                      expectation:
                        proc do
                          line do
                            plain "Expected "
                            actual "#<X>"
                            plain " to return a truthy result for "
                            expected "false?"
                            plain " or "
                            expected "falses?"
                            plain "."
                          end
                        end
                    )

                  expect(program).to produce_output_when_run(
                    expected_output
                  ).in_color(color_enabled).removing_object_ids
                end
              end
            end

            context "and is called neither #true? nor #false?" do
              context "and is singular" do
                context "when the inspected version of the actual   value is short" do
                  it "produces the correct failure message" do
                    as_both_colored_and_uncolored do |color_enabled|
                      snippet = <<~TEST.strip
                        class X
                          def y?; false; end
                        end

                        expect(X.new).to #{prefix}_y
                      TEST
                      program =
                        make_plain_test_program(
                          snippet,
                          color_enabled: color_enabled
                        )

                      expected_output =
                        build_expected_output(
                          color_enabled: color_enabled,
                          snippet: %|expect(X.new).to #{prefix}_y|,
                          expectation:
                            proc do
                              line do
                                plain "Expected "
                                actual "#<X>"
                                plain " to return a truthy result for "
                                expected "y?"
                                plain " or "
                                expected "ys?"
                                plain "."
                              end
                            end
                        )

                      expect(program).to produce_output_when_run(
                        expected_output
                      ).in_color(color_enabled).removing_object_ids
                    end
                  end
                end

                context "when the inspected version of the actual   value is long" do
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
                      program =
                        make_plain_test_program(
                          snippet,
                          color_enabled: color_enabled
                        )

                      expected_output =
                        build_expected_output(
                          color_enabled: color_enabled,
                          snippet: %|expect(hash).to #{prefix}_y|,
                          newline_before_expectation: true,
                          expectation:
                            proc do
                              line do
                                plain "                     Expected "
                                actual %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz", aaaaaa: "bbbbbb" }|
                              end

                              line do
                                plain "to return a truthy result for "
                                expected "y?"
                                plain " or "
                                expected "ys?"
                              end
                            end
                        )

                      expect(program).to produce_output_when_run(
                        expected_output
                      ).in_color(color_enabled).removing_object_ids
                    end
                  end
                end
              end

              context "and is plural" do
                context "when the inspected version of the actual   value is short" do
                  it "produces the correct failure message" do
                    as_both_colored_and_uncolored do |color_enabled|
                      snippet = <<~TEST.strip
                        class X
                          def ys?; false; end
                        end

                        expect(X.new).to #{prefix}_y
                      TEST
                      program =
                        make_plain_test_program(
                          snippet,
                          color_enabled: color_enabled
                        )

                      expected_output =
                        build_expected_output(
                          color_enabled: color_enabled,
                          snippet: %|expect(X.new).to #{prefix}_y|,
                          expectation:
                            proc do
                              line do
                                plain "Expected "
                                actual "#<X>"
                                plain " to return a truthy result for "
                                expected "y?"
                                plain " or "
                                expected "ys?"
                                plain "."
                              end
                            end
                        )

                      expect(program).to produce_output_when_run(
                        expected_output
                      ).in_color(color_enabled).removing_object_ids
                    end
                  end
                end

                context "when the inspected version of the actual   value is long" do
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
                      program =
                        make_plain_test_program(
                          snippet,
                          color_enabled: color_enabled
                        )

                      expected_output =
                        build_expected_output(
                          color_enabled: color_enabled,
                          snippet: %|expect(hash).to #{prefix}_y|,
                          newline_before_expectation: true,
                          expectation:
                            proc do
                              line do
                                plain "                     Expected "
                                actual %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz", aaaaaa: "bbbbbb" }|
                              end

                              line do
                                plain "to return a truthy result for "
                                expected "y?"
                                plain " or "
                                expected "ys?"
                              end
                            end
                        )

                      expect(program).to produce_output_when_run(
                        expected_output
                      ).in_color(color_enabled).removing_object_ids
                    end
                  end
                end
              end
            end
          end

          context "and returns true" do
            context "when the inspected version of the actual   value is short" do
              it "produces the correct failure message when used in the negative" do
                as_both_colored_and_uncolored do |color_enabled|
                  snippet = <<~TEST.strip
                    class Foo
                      def strong?; true; end
                    end

                    expect(Foo.new).not_to #{prefix}_strong
                  TEST
                  program =
                    make_plain_test_program(
                      snippet,
                      color_enabled: color_enabled
                    )

                  expected_output =
                    build_expected_output(
                      color_enabled: color_enabled,
                      snippet: %|expect(Foo.new).not_to #{prefix}_strong|,
                      expectation:
                        proc do
                          line do
                            plain "Expected "
                            actual "#<Foo>"
                            plain " not to return a truthy result for "
                            expected "strong?"
                            plain " or "
                            expected "strongs?"
                            plain "."
                          end
                        end
                    )

                  expect(program).to produce_output_when_run(
                    expected_output
                  ).in_color(color_enabled).removing_object_ids
                end
              end
            end

            context "when the inspected version of the actual   value is long" do
              it "produces the correct failure message when used in the negative" do
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
                      def ys?; true; end
                    end

                    expect(hash).not_to #{prefix}_y
                  TEST
                  program =
                    make_plain_test_program(
                      snippet,
                      color_enabled: color_enabled
                    )

                  expected_output =
                    build_expected_output(
                      color_enabled: color_enabled,
                      snippet: %|expect(hash).not_to #{prefix}_y|,
                      newline_before_expectation: true,
                      expectation:
                        proc do
                          line do
                            plain "                         Expected "
                            actual %|{ foo: "bar", baz: "qux", blargh: "foz", fizz: "buzz", aaaaaa: "bbbbbb" }|
                          end

                          line do
                            plain "not to return a truthy result for "
                            expected "y?"
                            plain " or "
                            expected "ys?"
                          end
                        end
                    )

                  expect(program).to produce_output_when_run(
                    expected_output
                  ).in_color(color_enabled).removing_object_ids
                end
              end
            end
          end
        end
      end
    end
  end
end
