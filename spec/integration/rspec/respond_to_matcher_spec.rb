require "spec_helper"

# TODO: Update coloring here
RSpec.describe "Integration with RSpec's #respond_to matcher", type: :integration do
  context "without any qualifiers" do
    context "when a few number of methods are specified" do
      it "produces the correct output" do
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
                green %|#<Double (anonymous)>|
                plain " to respond to "
                red %|:foo|
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
      it "produces the correct output" do
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
                green %|#<Double :something_really_long>|
              end

              line do
                plain "to respond to "
                red %|:foo|
                plain ", "
                red %|:bar|
                plain ", "
                red %|:baz|
                plain ", "
                red %|:qux|
                plain ", "
                red %|:fizz|
                plain ", "
                red %|:buzz|
                plain " and "
                red %|:zing|
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

  context "qualified with #with + #arguments" do
    context "when a few number of methods are specified" do
      it "produces the correct output" do
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
                green %|#<Double (anonymous)>|
                plain " to respond to "
                red %|:foo|
                plain " with "
                red %|3|
                plain " arguments."
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
      it "produces the correct output" do
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
                green %|#<Double :something_really_long>|
              end

              line do
                plain "to respond to "
                red %|:foo|
                plain ", "
                red %|:bar|
                plain ", "
                red %|:baz|
                plain ", "
                red %|:fizz|
                plain " and "
                red %|:buzz|
                plain " with "
                red %|3|
                plain " arguments"
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

  context "qualified with #with_keywords" do
    context "when a few number of methods are specified" do
      it "produces the correct output" do
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
                green %|#<Double (anonymous)>|
                plain " to respond to "
                red %|:foo|
                plain " with keyword "
                red %|:bar|
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
      it "produces the correct output" do
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
                green %|#<Double :something_really_long>|
              end

              line do
                plain "to respond to "
                red %|:foo|
                plain ", "
                red %|:bar|
                plain ", "
                red %|:baz|
                plain ", "
                red %|:fizz|
                plain " and "
                red %|:buzz|
                plain " with keywords "
                red %|:qux|
                plain " and "
                red %|:blargh|
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

  context "qualified with #with_any_keywords" do
    context "when a few number of methods are specified" do
      it "produces the correct output" do
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
                green %|#<Double (anonymous)>|
                plain " to respond to "
                red %|:foo|
                plain " with "
                red %|any|
                plain " keywords."
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
      it "produces the correct output" do
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
                green %|#<Double :something_really_long>|
              end

              line do
                plain "to respond to "
                red %|:foo|
                plain ", "
                red %|:bar|
                plain ", "
                red %|:baz|
                plain ", "
                red %|:qux|
                plain ", "
                red %|:fizz|
                plain " and "
                red %|:buzz|
                plain " with "
                red %|any|
                plain " keywords "
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

  context "qualified with #with_unlimited_arguments" do
    context "when a few number of methods are specified" do
      it "produces the correct output" do
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
                green %|#<Double (anonymous)>|
                plain " to respond to "
                red %|:foo|
                plain " with "
                red %|unlimited|
                plain " arguments."
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
      it "produces the correct output" do
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
                green %|#<Double :something_really_long>|
              end

              line do
                plain "to respond to "
                red %|:foo|
                plain ", "
                red %|:bar|
                plain " and "
                red %|:baz|
                plain " with "
                red %|unlimited|
                plain " arguments"
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

  context "qualified with #with_any_keywords + #with_unlimited_arguments" do
    it "produces the correct output" do
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
              green %|#<Double :something_really_long>|
            end

            line do
              plain "to respond to "
              red %|:foo|
              plain ", "
              red %|:bar|
              plain " and "
              red %|:baz|
              plain " with "
              red %|any|
              plain " keywords and "
              red %|unlimited|
              plain " arguments"
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "qualified with #with_keywords + #with_unlimited_arguments" do
    it "produces the correct output" do
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
              green %|#<Double :something_really_long>|
            end

            line do
              plain "to respond to "
              red %|:foo|
              plain ", "
              red %|:bar|
              plain " and "
              red %|:baz|
              plain " with keywords "
              red %|:qux|
              plain " and "
              red %|:blargh|
              plain " and "
              red %|unlimited|
              plain " arguments"
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
