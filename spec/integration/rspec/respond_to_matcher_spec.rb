require "spec_helper"

# TODO: Update coloring here
RSpec.describe "Integration with RSpec's #respond_to matcher", type: :integration do
  context "without any qualifiers" do
    context "when a few number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = %|expect(double).to respond_to(:foo)|
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
                beta %|#<Double (anonymous)>|
                plain " to respond to "
                alpha %|:foo|
                plain "."
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = %|expect(double).not_to respond_to(:inspect)|
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
                beta %|#<Double (anonymous)>|
                plain " not to respond to "
                alpha %|:inspect|
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

    context "when a large number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :qux, :fizz, :buzz, :zing)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :qux, :fizz, :buzz, :zing)|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "     Expected "
                beta %|#<Double :something_really_long>|
              end

              line do
                plain "to respond to "
                alpha %|:foo|
                plain ", "
                alpha %|:bar|
                plain ", "
                alpha %|:baz|
                plain ", "
                alpha %|:qux|
                plain ", "
                alpha %|:fizz|
                plain ", "
                alpha %|:buzz|
                plain " and "
                alpha %|:zing|
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
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
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(B.new).not_to respond_to(:some_really_long_method_and_stuff, :another_method_or_whatever)|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "         Expected "
                beta %|#<B>|
              end

              line do
                plain "not to respond to "
                alpha %|:some_really_long_method_and_stuff|
                plain " and "
                alpha %|:another_method_or_whatever|
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

  context "qualified with #with + #arguments" do
    context "when a few number of methods are specified when used in the positive" do
      it "produces the correct failure message" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double).to respond_to(:foo).with(3).arguments
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(double).to respond_to(:foo).with(3).arguments|,
            expectation: proc {
              line do
                plain "Expected "
                beta %|#<Double (anonymous)>|
                plain " to respond to "
                alpha %|:foo|
                plain " with "
                alpha %|3|
                plain " arguments."
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
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
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(B.new).not_to respond_to(:foo).with(3).arguments|,
            expectation: proc {
              line do
                plain "Expected "
                beta %|#<B>|
                plain " not to respond to "
                alpha %|:foo|
                plain " with "
                alpha %|3|
                plain " arguments."
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

    context "when a large number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :fizz, :buzz).with(3).arguments
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :fizz, :buzz).with(3).arguments|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "     Expected "
                beta %|#<Double :something_really_long>|
              end

              line do
                plain "to respond to "
                alpha %|:foo|
                plain ", "
                alpha %|:bar|
                plain ", "
                alpha %|:baz|
                plain ", "
                alpha %|:fizz|
                plain " and "
                alpha %|:buzz|
                plain " with "
                alpha %|3|
                plain " arguments"
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
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
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(B.new).not_to respond_to(:some_really_long_method_and_stuff, :another_method_or_whatever).with(3).arguments|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "         Expected "
                beta %|#<B>|
              end

              line do
                plain "not to respond to "
                alpha %|:some_really_long_method_and_stuff|
                plain " and "
                alpha %|:another_method_or_whatever|
                plain " with "
                alpha %|3|
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

  context "qualified with #with_keywords" do
    context "when a few number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double).to respond_to(:foo).with_keywords(:bar)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(double).to respond_to(:foo).with_keywords(:bar)|,
            expectation: proc {
              line do
                plain "Expected "
                beta %|#<Double (anonymous)>|
                plain " to respond to "
                alpha %|:foo|
                plain " with keyword "
                alpha %|:bar|
                plain "."
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
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
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(B.new).not_to respond_to(:foo).with_keywords(:bar)|,
            expectation: proc {
              line do
                plain "Expected "
                beta %|#<B>|
                plain " not to respond to "
                alpha %|:foo|
                plain " with keyword "
                alpha %|:bar|
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
    end

    context "when a large number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :fizz, :buzz).with_keywords(:qux, :blargh)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :fizz, :buzz).with_keywords(:qux, :blargh)|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "     Expected "
                beta %|#<Double :something_really_long>|
              end

              line do
                plain "to respond to "
                alpha %|:foo|
                plain ", "
                alpha %|:bar|
                plain ", "
                alpha %|:baz|
                plain ", "
                alpha %|:fizz|
                plain " and "
                alpha %|:buzz|
                plain " with keywords "
                alpha %|:qux|
                plain " and "
                alpha %|:blargh|
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
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
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(B.new).not_to respond_to(:some_really_long_method_and_stuff, :another_method_or_whatever).with_keywords(:foo, :bar)|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "         Expected "
                beta %|#<B>|
              end

              line do
                plain "not to respond to "
                alpha %|:some_really_long_method_and_stuff|
                plain " and "
                alpha %|:another_method_or_whatever|
                plain " with keywords "
                alpha %|:foo|
                plain " and "
                alpha %|:bar|
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

  context "qualified with #with_any_keywords" do
    context "when a few number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double).to respond_to(:foo).with_any_keywords
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(double).to respond_to(:foo).with_any_keywords|,
            expectation: proc {
              line do
                plain "Expected "
                beta %|#<Double (anonymous)>|
                plain " to respond to "
                alpha %|:foo|
                plain " with "
                alpha %|any|
                plain " keywords."
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
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
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(B.new).not_to respond_to(:foo).with_any_keywords|,
            expectation: proc {
              line do
                plain "Expected "
                beta %|#<B>|
                plain " not to respond to "
                alpha %|:foo|
                plain " with "
                alpha %|any|
                plain " keywords."
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

    context "when a large number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :qux, :fizz, :buzz).with_any_keywords
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz, :qux, :fizz, :buzz).with_any_keywords|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "     Expected "
                beta %|#<Double :something_really_long>|
              end

              line do
                plain "to respond to "
                alpha %|:foo|
                plain ", "
                alpha %|:bar|
                plain ", "
                alpha %|:baz|
                plain ", "
                alpha %|:qux|
                plain ", "
                alpha %|:fizz|
                plain " and "
                alpha %|:buzz|
                plain " with "
                alpha %|any|
                plain " keywords "
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
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
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(B.new).not_to respond_to(:some_really_long_method_and_stuff, :another_method_or_whatever).with_any_keywords|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "         Expected "
                beta %|#<B>|
              end

              line do
                plain "not to respond to "
                alpha %|:some_really_long_method_and_stuff|
                plain " and "
                alpha %|:another_method_or_whatever|
                plain " with "
                alpha %|any|
                plain " keywords "
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

  context "qualified with #with_unlimited_arguments" do
    context "when a few number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double).to respond_to(:foo).with_unlimited_arguments
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(double).to respond_to(:foo).with_unlimited_arguments|,
            expectation: proc {
              line do
                plain "Expected "
                beta %|#<Double (anonymous)>|
                plain " to respond to "
                alpha %|:foo|
                plain " with "
                alpha %|unlimited|
                plain " arguments."
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
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
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(B.new).not_to respond_to(:foo).with_unlimited_arguments|,
            expectation: proc {
              line do
                plain "Expected "
                beta %|#<B>|
                plain " not to respond to "
                alpha %|:foo|
                plain " with "
                alpha %|unlimited|
                plain " arguments."
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

    context "when a large number of methods are specified" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_unlimited_arguments
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_unlimited_arguments|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "     Expected "
                beta %|#<Double :something_really_long>|
              end

              line do
                plain "to respond to "
                alpha %|:foo|
                plain ", "
                alpha %|:bar|
                plain " and "
                alpha %|:baz|
                plain " with "
                alpha %|unlimited|
                plain " arguments"
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
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
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(B.new).not_to respond_to(:some_really_long_method_and_stuff, :another_method_or_whatever).with_unlimited_arguments|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "         Expected "
                beta %|#<B>|
              end

              line do
                plain "not to respond to "
                alpha %|:some_really_long_method_and_stuff|
                plain " and "
                alpha %|:another_method_or_whatever|
                plain " with "
                alpha %|unlimited|
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

  context "qualified with #with_any_keywords + #with_unlimited_arguments" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_any_keywords.with_unlimited_arguments
        TEST
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_any_keywords.with_unlimited_arguments|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain "     Expected "
              beta %|#<Double :something_really_long>|
            end

            line do
              plain "to respond to "
              alpha %|:foo|
              plain ", "
              alpha %|:bar|
              plain " and "
              alpha %|:baz|
              plain " with "
              alpha %|any|
              plain " keywords and "
              alpha %|unlimited|
              plain " arguments"
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
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
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(B.new).not_to respond_to(:foo, :bar, :baz).with_any_keywords.with_unlimited_arguments|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain "         Expected "
              beta %|#<B>|
            end

            line do
              plain "not to respond to "
              alpha %|:foo|
              plain ", "
              alpha %|:bar|
              plain " and "
              alpha %|:baz|
              plain " with "
              alpha %|any|
              plain " keywords and "
              alpha %|unlimited|
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

  context "qualified with #with_keywords + #with_unlimited_arguments" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_keywords(:qux, :blargh).with_unlimited_arguments
        TEST
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(double(:something_really_long)).to respond_to(:foo, :bar, :baz).with_keywords(:qux, :blargh).with_unlimited_arguments|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain "     Expected "
              beta %|#<Double :something_really_long>|
            end

            line do
              plain "to respond to "
              alpha %|:foo|
              plain ", "
              alpha %|:bar|
              plain " and "
              alpha %|:baz|
              plain " with keywords "
              alpha %|:qux|
              plain " and "
              alpha %|:blargh|
              plain " and "
              alpha %|unlimited|
              plain " arguments"
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
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
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(B.new).not_to respond_to(:foo, :bar, :baz).with_keywords(:qux, :blargh).with_unlimited_arguments|,
          newline_before_expectation: true,
          expectation: proc {
            line do
              plain "         Expected "
              beta %|#<B>|
            end

            line do
              plain "not to respond to "
              alpha %|:foo|
              plain ", "
              alpha %|:bar|
              plain " and "
              alpha %|:baz|
              plain " with keywords "
              alpha %|:qux|
              plain " and "
              alpha %|:blargh|
              plain " and "
              alpha %|unlimited|
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
