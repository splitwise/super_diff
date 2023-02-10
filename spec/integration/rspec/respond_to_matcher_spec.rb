require "spec_helper"

# TODO: Update coloring here
RSpec.describe "Integration with RSpec's #respond_to matcher",
               type: :integration do
  context "without any qualifiers" do
    context "when a few number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = "expect(double).to respond_to(:foo)"
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
                    actual "#<Double (anonymous)>"
                    plain " to respond to "
                    expected ":foo"
                    plain "."
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = "expect(double).not_to respond_to(:inspect)"
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
                    actual "#<Double (anonymous)>"
                    plain " not to respond to "
                    expected ":inspect"
                    plain "."
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end
    end

    context "when a large number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :qux, :fizz, :buzz, :zing)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :qux, :fizz, :buzz, :zing)",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "     Expected "
                    actual "#<Double :something_really_long>"
                  end

                  line do
                    plain "to respond to "
                    expected ":foo"
                    plain ", "
                    expected ":bar"
                    plain ", "
                    expected ":baz"
                    plain ", "
                    expected ":qux"
                    plain ", "
                    expected ":fizz"
                    plain ", "
                    expected ":buzz"
                    plain " and "
                    expected ":zing"
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            class B
              def some_really_long_method_and_stuff; end
              def another_method_or_whatever; end
            end

            expect(B.new).not_to respond_to(:some_really_long_method_and_stuff, :another_method_or_whatever)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(B.new).not_to respond_to(:some_really_long_method_and_stuff, :another_method_or_whatever)",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "         Expected "
                    actual "#<B>"
                  end

                  line do
                    plain "not to respond to "
                    expected ":some_really_long_method_and_stuff"
                    plain " and "
                    expected ":another_method_or_whatever"
                  end
                end
            )

          expect(program).to produce_output_when_run(
            expected_output
          ).removing_object_ids.in_color(color_enabled)
        end
      end
    end
  end

  context "qualified with #with + #arguments" do
    context "when a few number of methods are specified when used in the positive" do
      it "produces the correct failure message" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double).to respond_to(:foo).with(3).arguments
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(double).to respond_to(:foo).with(3).arguments",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual "#<Double (anonymous)>"
                    plain " to respond to "
                    expected ":foo"
                    plain " with "
                    expected "3"
                    plain " arguments."
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            class B
              def foo(bar, baz, qux); end
            end

            expect(B.new).not_to respond_to(:foo).with(3).arguments
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(B.new).not_to respond_to(:foo).with(3).arguments",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual "#<B>"
                    plain " not to respond to "
                    expected ":foo"
                    plain " with "
                    expected "3"
                    plain " arguments."
                  end
                end
            )

          expect(program).to produce_output_when_run(
            expected_output
          ).removing_object_ids.in_color(color_enabled)
        end
      end
    end

    context "when a large number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :fizz, :buzz).with(3).arguments
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :fizz, :buzz).with(3).arguments",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "     Expected "
                    actual "#<Double :something_really_long>"
                  end

                  line do
                    plain "to respond to "
                    expected ":foo"
                    plain ", "
                    expected ":bar"
                    plain ", "
                    expected ":baz"
                    plain ", "
                    expected ":fizz"
                    plain " and "
                    expected ":buzz"
                    plain " with "
                    expected "3"
                    plain " arguments"
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            class B
              def some_really_long_method_and_stuff(foo, bar, baz); end
              def another_method_or_whatever(foo, bar, baz); end
            end

            expect(B.new).not_to respond_to(:some_really_long_method_and_stuff, :another_method_or_whatever).with(3).arguments
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(B.new).not_to respond_to(:some_really_long_method_and_stuff, :another_method_or_whatever).with(3).arguments",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "         Expected "
                    actual "#<B>"
                  end

                  line do
                    plain "not to respond to "
                    expected ":some_really_long_method_and_stuff"
                    plain " and "
                    expected ":another_method_or_whatever"
                    plain " with "
                    expected "3"
                    plain " arguments"
                  end
                end
            )

          expect(program).to produce_output_when_run(
            expected_output
          ).removing_object_ids.in_color(color_enabled)
        end
      end
    end
  end

  context "qualified with #with_keywords" do
    context "when a few number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double).to respond_to(:foo).with_keywords(:bar)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(double).to respond_to(:foo).with_keywords(:bar)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual "#<Double (anonymous)>"
                    plain " to respond to "
                    expected ":foo"
                    plain " with keyword "
                    expected ":bar"
                    plain "."
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            class B
              def foo(bar:); end
            end

            expect(B.new).not_to respond_to(:foo).with_keywords(:bar)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(B.new).not_to respond_to(:foo).with_keywords(:bar)",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual "#<B>"
                    plain " not to respond to "
                    expected ":foo"
                    plain " with keyword "
                    expected ":bar"
                    plain "."
                  end
                end
            )

          expect(program).to produce_output_when_run(
            expected_output
          ).removing_object_ids.in_color(color_enabled)
        end
      end
    end

    context "when a large number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :fizz, :buzz).with_keywords(:qux, :blargh)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :fizz, :buzz).with_keywords(:qux, :blargh)",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "     Expected "
                    actual "#<Double :something_really_long>"
                  end

                  line do
                    plain "to respond to "
                    expected ":foo"
                    plain ", "
                    expected ":bar"
                    plain ", "
                    expected ":baz"
                    plain ", "
                    expected ":fizz"
                    plain " and "
                    expected ":buzz"
                    plain " with keywords "
                    expected ":qux"
                    plain " and "
                    expected ":blargh"
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            class B
              def some_really_long_method_and_stuff(foo:, bar:); end
              def another_method_or_whatever(foo:, bar:); end
            end

            expect(B.new).not_to respond_to(:some_really_long_method_and_stuff, :another_method_or_whatever).with_keywords(:foo, :bar)
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(B.new).not_to respond_to(:some_really_long_method_and_stuff, :another_method_or_whatever).with_keywords(:foo, :bar)",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "         Expected "
                    actual "#<B>"
                  end

                  line do
                    plain "not to respond to "
                    expected ":some_really_long_method_and_stuff"
                    plain " and "
                    expected ":another_method_or_whatever"
                    plain " with keywords "
                    expected ":foo"
                    plain " and "
                    expected ":bar"
                  end
                end
            )

          expect(program).to produce_output_when_run(
            expected_output
          ).removing_object_ids.in_color(color_enabled)
        end
      end
    end
  end

  context "qualified with #with_any_keywords" do
    context "when a few number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double).to respond_to(:foo).with_any_keywords
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet: "expect(double).to respond_to(:foo).with_any_keywords",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual "#<Double (anonymous)>"
                    plain " to respond to "
                    expected ":foo"
                    plain " with "
                    expected "any"
                    plain " keywords."
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            class B
              def foo(**options); end
            end

            expect(B.new).not_to respond_to(:foo).with_any_keywords
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(B.new).not_to respond_to(:foo).with_any_keywords",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual "#<B>"
                    plain " not to respond to "
                    expected ":foo"
                    plain " with "
                    expected "any"
                    plain " keywords."
                  end
                end
            )

          expect(program).to produce_output_when_run(
            expected_output
          ).removing_object_ids.in_color(color_enabled)
        end
      end
    end

    context "when a large number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :qux, :fizz, :buzz).with_any_keywords
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :qux, :fizz, :buzz).with_any_keywords",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "     Expected "
                    actual "#<Double :something_really_long>"
                  end

                  line do
                    plain "to respond to "
                    expected ":foo"
                    plain ", "
                    expected ":bar"
                    plain ", "
                    expected ":baz"
                    plain ", "
                    expected ":qux"
                    plain ", "
                    expected ":fizz"
                    plain " and "
                    expected ":buzz"
                    plain " with "
                    expected "any"
                    plain " keywords "
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            class B
              def some_really_long_method_and_stuff(**options); end
              def another_method_or_whatever(**options); end
            end

            expect(B.new).not_to respond_to(:some_really_long_method_and_stuff, :another_method_or_whatever).with_any_keywords
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(B.new).not_to respond_to(:some_really_long_method_and_stuff, :another_method_or_whatever).with_any_keywords",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "         Expected "
                    actual "#<B>"
                  end

                  line do
                    plain "not to respond to "
                    expected ":some_really_long_method_and_stuff"
                    plain " and "
                    expected ":another_method_or_whatever"
                    plain " with "
                    expected "any"
                    plain " keywords "
                  end
                end
            )

          expect(program).to produce_output_when_run(
            expected_output
          ).removing_object_ids.in_color(color_enabled)
        end
      end
    end
  end

  context "qualified with #with_unlimited_arguments" do
    context "when a few number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double).to respond_to(:foo).with_unlimited_arguments
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(double).to respond_to(:foo).with_unlimited_arguments",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual "#<Double (anonymous)>"
                    plain " to respond to "
                    expected ":foo"
                    plain " with "
                    expected "unlimited"
                    plain " arguments."
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            class B
              def foo(*args); end
            end

            expect(B.new).not_to respond_to(:foo).with_unlimited_arguments
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(B.new).not_to respond_to(:foo).with_unlimited_arguments",
              expectation:
                proc do
                  line do
                    plain "Expected "
                    actual "#<B>"
                    plain " not to respond to "
                    expected ":foo"
                    plain " with "
                    expected "unlimited"
                    plain " arguments."
                  end
                end
            )

          expect(program).to produce_output_when_run(
            expected_output
          ).removing_object_ids.in_color(color_enabled)
        end
      end
    end

    context "when a large number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_unlimited_arguments
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_unlimited_arguments",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "     Expected "
                    actual "#<Double :something_really_long>"
                  end

                  line do
                    plain "to respond to "
                    expected ":foo"
                    plain ", "
                    expected ":bar"
                    plain " and "
                    expected ":baz"
                    plain " with "
                    expected "unlimited"
                    plain " arguments"
                  end
                end
            )

          expect(program).to produce_output_when_run(expected_output).in_color(
            color_enabled
          )
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            class B
              def some_really_long_method_and_stuff(*args); end
              def another_method_or_whatever(*args); end
            end

            expect(B.new).not_to respond_to(:some_really_long_method_and_stuff, :another_method_or_whatever).with_unlimited_arguments
          TEST
          program =
            make_plain_test_program(snippet, color_enabled: color_enabled)

          expected_output =
            build_expected_output(
              color_enabled: color_enabled,
              snippet:
                "expect(B.new).not_to respond_to(:some_really_long_method_and_stuff, :another_method_or_whatever).with_unlimited_arguments",
              newline_before_expectation: true,
              expectation:
                proc do
                  line do
                    plain "         Expected "
                    actual "#<B>"
                  end

                  line do
                    plain "not to respond to "
                    expected ":some_really_long_method_and_stuff"
                    plain " and "
                    expected ":another_method_or_whatever"
                    plain " with "
                    expected "unlimited"
                    plain " arguments"
                  end
                end
            )

          expect(program).to produce_output_when_run(
            expected_output
          ).removing_object_ids.in_color(color_enabled)
        end
      end
    end
  end

  context "qualified with #with_any_keywords + #with_unlimited_arguments" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_any_keywords.with_unlimited_arguments
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet:
              "expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_any_keywords.with_unlimited_arguments",
            newline_before_expectation: true,
            expectation:
              proc do
                line do
                  plain "     Expected "
                  actual "#<Double :something_really_long>"
                end

                line do
                  plain "to respond to "
                  expected ":foo"
                  plain ", "
                  expected ":bar"
                  plain " and "
                  expected ":baz"
                  plain " with "
                  expected "any"
                  plain " keywords and "
                  expected "unlimited"
                  plain " arguments"
                end
              end
          )

        expect(program).to produce_output_when_run(expected_output).in_color(
          color_enabled
        )
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          class B
            def foo(*args, **options); end
            def bar(*args, **options); end
            def baz(*args, **options); end
          end

          expect(B.new).not_to respond_to(:foo, :bar, :baz).with_any_keywords.with_unlimited_arguments
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet:
              "expect(B.new).not_to respond_to(:foo, :bar, :baz).with_any_keywords.with_unlimited_arguments",
            newline_before_expectation: true,
            expectation:
              proc do
                line do
                  plain "         Expected "
                  actual "#<B>"
                end

                line do
                  plain "not to respond to "
                  expected ":foo"
                  plain ", "
                  expected ":bar"
                  plain " and "
                  expected ":baz"
                  plain " with "
                  expected "any"
                  plain " keywords and "
                  expected "unlimited"
                  plain " arguments"
                end
              end
          )

        expect(program).to produce_output_when_run(
          expected_output
        ).removing_object_ids.in_color(color_enabled)
      end
    end
  end

  context "qualified with #with_keywords + #with_unlimited_arguments" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_keywords(:qux, :blargh).with_unlimited_arguments
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet:
              "expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_keywords(:qux, :blargh).with_unlimited_arguments",
            newline_before_expectation: true,
            expectation:
              proc do
                line do
                  plain "     Expected "
                  actual "#<Double :something_really_long>"
                end

                line do
                  plain "to respond to "
                  expected ":foo"
                  plain ", "
                  expected ":bar"
                  plain " and "
                  expected ":baz"
                  plain " with keywords "
                  expected ":qux"
                  plain " and "
                  expected ":blargh"
                  plain " and "
                  expected "unlimited"
                  plain " arguments"
                end
              end
          )

        expect(program).to produce_output_when_run(expected_output).in_color(
          color_enabled
        )
      end
    end

    it "produces the correct failure message when used in the negative" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          class B
            def foo(*args, qux:, blargh:); end
            def bar(*args, qux:, blargh:); end
            def baz(*args, qux:, blargh:); end
          end

          expect(B.new).not_to respond_to(:foo, :bar, :baz).with_keywords(:qux, :blargh).with_unlimited_arguments
        TEST
        program = make_plain_test_program(snippet, color_enabled: color_enabled)

        expected_output =
          build_expected_output(
            color_enabled: color_enabled,
            snippet:
              "expect(B.new).not_to respond_to(:foo, :bar, :baz).with_keywords(:qux, :blargh).with_unlimited_arguments",
            newline_before_expectation: true,
            expectation:
              proc do
                line do
                  plain "         Expected "
                  actual "#<B>"
                end

                line do
                  plain "not to respond to "
                  expected ":foo"
                  plain ", "
                  expected ":bar"
                  plain " and "
                  expected ":baz"
                  plain " with keywords "
                  expected ":qux"
                  plain " and "
                  expected ":blargh"
                  plain " and "
                  expected "unlimited"
                  plain " arguments"
                end
              end
          )

        expect(program).to produce_output_when_run(
          expected_output
        ).removing_object_ids.in_color(color_enabled)
      end
    end
  end
end
