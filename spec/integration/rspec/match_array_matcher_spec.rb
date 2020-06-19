require "spec_helper"

RSpec.describe "Integration with RSpec's #match_array matcher", type: :integration do
  context "when a few number of values are given" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = ["Einie", "Marty"]
          actual   = ["Marty", "Jennifer", "Doc"]
          expect(actual).to match_array(expected)
        TEST
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(actual).to match_array(expected)|,
          expectation: proc {
            line do
              plain    %|Expected |
              actual   %|["Marty", "Jennifer", "Doc"]|
              plain    %| to match array with |
              expected %|"Einie"|
              plain    %| and |
              expected %|"Marty"|
              plain    %|.|
            end
          },
          diff: proc {
            plain_line    %|  [|
            plain_line    %|    "Marty",|
            actual_line   %|+   "Jennifer",|
            actual_line   %|+   "Doc",|
            # expected_line %|-   "Einie"|  # TODO
            expected_line %|-   "Einie",|
            plain_line    %|  ]|
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
          values = ["Einie", "Marty"]
          expect(values).not_to match_array(values)
        TEST
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(values).not_to match_array(values)|,
          expectation: proc {
            line do
              plain    %|Expected |
              actual   %|["Einie", "Marty"]|
              plain    %| not to match array with |
              expected %|"Einie"|
              plain    %| and |
              expected %|"Marty"|
              plain    %|.|
            end
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end

  context "when a large number of values are given" do
    context "and they are only simple strings" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = [
              "Doc Brown",
              "Marty McFly",
              "Biff Tannen",
              "George McFly",
              "Lorraine McFly"
            ]
            actual   = [
              "Marty McFly",
              "Doc Brown",
              "Einie",
              "Lorraine McFly"
            ]
            expect(actual).to match_array(expected)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(actual).to match_array(expected)|,
            expectation: proc {
              line do
                plain    %|           Expected |
                actual   %|["Marty McFly", "Doc Brown", "Einie", "Lorraine McFly"]|
              end

              line do
                plain    %|to match array with |
                expected %|"Doc Brown"|
                plain    %|, |
                expected %|"Marty McFly"|
                plain    %|, |
                expected %|"Biff Tannen"|
                plain    %|, |
                expected %|"George McFly"|
                plain    %| and |
                expected %|"Lorraine McFly"|
              end
            },
            diff: proc {
              plain_line    %|  [|
              plain_line    %|    "Marty McFly",|
              plain_line    %|    "Doc Brown",|
              plain_line    %|    "Lorraine McFly",|
              actual_line   %|+   "Einie",|
              expected_line %|-   "Biff Tannen",|
              # expected_line %|-   "George McFly"|  # TODO
              expected_line %|-   "George McFly",|
              plain_line    %|  ]|
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
            values = [
              "Marty McFly",
              "Doc Brown",
              "Einie",
              "Lorraine McFly"
            ]
            expect(values).not_to match_array(values)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(values).not_to match_array(values)|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain    %|               Expected |
                actual   %|["Marty McFly", "Doc Brown", "Einie", "Lorraine McFly"]|
              end

              line do
                plain    %|not to match array with |
                expected %|"Marty McFly"|
                plain    %|, |
                expected %|"Doc Brown"|
                plain    %|, |
                expected %|"Einie"|
                plain    %| and |
                expected %|"Lorraine McFly"|
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end

    context "and some of them are regexen" do
      it "produces the correct failure message when used in the positive" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST
            expected = [
              / Brown$/,
              "Marty McFly",
              "Biff Tannen",
              /Georg McFly/,
              /Lorrain McFly/
            ]
            actual   = [
              "Marty McFly",
              "Doc Brown",
              "Einie",
              "Lorraine McFly"
            ]
            expect(actual).to match_array(expected)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(actual).to match_array(expected)|,
            expectation: proc {
              line do
                plain    %|           Expected |
                actual   %|["Marty McFly", "Doc Brown", "Einie", "Lorraine McFly"]|
              end

              line do
                plain    %|to match array with |
                expected %|/ Brown$/|
                plain    %|, |
                expected %|"Marty McFly"|
                plain    %|, |
                expected %|"Biff Tannen"|
                plain    %|, |
                expected %|/Georg McFly/|
                plain    %| and |
                expected %|/Lorrain McFly/|
              end
            },
            diff: proc {
              plain_line    %|  [|
              plain_line    %|    "Marty McFly",|
              plain_line    %|    "Doc Brown",|
              actual_line   %|+   "Einie",|
              actual_line   %|+   "Lorraine McFly",|
              expected_line %|-   "Biff Tannen",|
              expected_line %|-   /Georg McFly/,|
              # expected_line %|-   /Lorrain McFly/|  # TODO
              expected_line %|-   /Lorrain McFly/,|
              plain_line    %|  ]|
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end

      it "produces the correct failure message when used in the negative" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST
            values = [
              / Brown$/,
              "Marty McFly",
              "Biff Tannen",
              /Georg McFly/,
              /Lorrain McFly/
            ]
            expect(values).not_to match_array(values)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(values).not_to match_array(values)|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain    %|               Expected |
                # rubocop:disable Metrics/LineLength
                actual   %|[/ Brown$/, "Marty McFly", "Biff Tannen", /Georg McFly/, /Lorrain McFly/]|
                # rubocop:enable Metrics/LineLength
              end

              line do
                plain    %|not to match array with |
                expected %|/ Brown$/|
                plain    %|, |
                expected %|"Marty McFly"|
                plain    %|, |
                expected %|"Biff Tannen"|
                plain    %|, |
                expected %|/Georg McFly/|
                plain    %| and |
                expected %|/Lorrain McFly/|
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end

    context "and some of them are fuzzy objects" do
      it "produces the correct failure message" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = [
              a_hash_including(foo: "bar"),
              a_collection_containing_exactly("zing"),
              an_object_having_attributes(baz: "qux"),
            ]
            actual   = [
              { foo: "bar" },
              double(baz: "qux"),
              { blargh: "riddle" }
            ]
            expect(actual).to match_array(expected)
          TEST
          program = make_plain_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(actual).to match_array(expected)|,
            expectation: proc {
              line do
                plain    %|           Expected |
                # rubocop:disable Metrics/LineLength
                actual   %|[{ foo: "bar" }, #<Double (anonymous) baz: "qux">, { blargh: "riddle" }]|
                # rubocop:enable Metrics/LineLength
              end

              line do
                plain    %|to match array with |
                expected %|#<a hash including (foo: "bar")>|
                plain    %|, |
                expected %|#<a collection containing exactly ("zing")>|
                plain    %| and |
                expected %|#<an object having attributes (baz: "qux")>|
              end
            },
            diff: proc {
              plain_line    %|  [|
              plain_line    %|    {|
              plain_line    %|      foo: "bar"|
              plain_line    %|    },|
              plain_line    %|    #<Double (anonymous) {|
              plain_line    %|      baz: "qux"|
              plain_line    %|    }>,|
              actual_line   %|+   {|
              actual_line   %|+     blargh: "riddle"|
              actual_line   %|+   },|
              expected_line %|-   #<a collection containing exactly (|
              expected_line %|-     "zing"|
              # expected_line %|-   )>|  # TODO
              expected_line %|-   )>,|
              plain_line    %|  ]|
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end
  end

  context "when the input value is a string" do
    it "produces the correct failure message when used in the positive" do
      as_both_colored_and_uncolored do |color_enabled|
        snippet = <<~TEST.strip
          expected = "Einie"
          actual   = ["Marty", "Jennifer", "Doc"]
          expect(actual).to match_array(expected)
        TEST
        program = make_plain_test_program(
          snippet,
          color_enabled: color_enabled,
        )

        expected_output = build_expected_output(
          color_enabled: color_enabled,
          snippet: %|expect(actual).to match_array(expected)|,
          expectation: proc {
            line do
              plain    %|Expected |
              actual   %|["Marty", "Jennifer", "Doc"]|
              plain    %| to match array with |
              expected %|"Einie"|
              plain    %|.|
            end
          },
          diff: proc {
            plain_line    %|  [|
            actual_line   %|+   "Marty",|
            actual_line   %|+   "Jennifer",|
            actual_line   %|+   "Doc",|
            # expected_line %|-   "Einie"|  # TODO
            expected_line %|-   "Einie",|
            plain_line    %|  ]|
          },
        )

        expect(program).
          to produce_output_when_run(expected_output).
          in_color(color_enabled)
      end
    end
  end
end
