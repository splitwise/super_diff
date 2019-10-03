shared_examples_for "integration with HashWithIndifferentAccess" do
  describe "and RSpec's #eq matcher" do
    context "when the actual value is a HashWithIndifferentAccess" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = {
              line_1: "123 Main St.",
              city: "Hill Valley",
              state: "CA",
              zip: "90382",
            }
            actual = HashWithIndifferentAccess.new({
              line_1: "456 Ponderosa Ct.",
              city: "Oakland",
              state: "CA",
              zip: "91234",
            })
            expect(actual).to eq(expected)
          TEST
          program = make_rspec_rails_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to eq(expected)",
            expectation: proc {
              line do
                plain "Expected "
                beta %|#<HashWithIndifferentAccess { "line_1" => "456 Ponderosa Ct.", "city" => "Oakland", "state" => "CA", "zip" => "91234" }>|
              end

              line do
                plain "   to eq "
                alpha %|{ line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" }|
              end
            },
            diff: proc {
              plain_line %|  #<HashWithIndifferentAccess {|
              alpha_line %|-   "line_1" => "123 Main St.",|
              beta_line %|+   "line_1" => "456 Ponderosa Ct.",|
              alpha_line %|-   "city" => "Hill Valley",|
              beta_line %|+   "city" => "Oakland",|
              plain_line %|    "state" => "CA",|
              alpha_line %|-   "zip" => "90382"|
              beta_line %|+   "zip" => "91234"|
              plain_line %|  }>|
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end

    context "when the expected value is a HashWithIndifferentAccess" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = HashWithIndifferentAccess.new({
              line_1: "456 Ponderosa Ct.",
              city: "Oakland",
              state: "CA",
              zip: "91234",
            })
            actual = {
              line_1: "123 Main St.",
              city: "Hill Valley",
              state: "CA",
              zip: "90382",
            }
            expect(actual).to eq(expected)
          TEST
          program = make_rspec_rails_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to eq(expected)",
            expectation: proc {
              line do
                plain "Expected "
                beta %|{ line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" }|
              end

              line do
                plain "   to eq "
                alpha %|#<HashWithIndifferentAccess { "line_1" => "456 Ponderosa Ct.", "city" => "Oakland", "state" => "CA", "zip" => "91234" }>|
              end
            },
            diff: proc {
              plain_line %|  #<HashWithIndifferentAccess {|
              alpha_line %|-   "line_1" => "456 Ponderosa Ct.",|
              beta_line %|+   "line_1" => "123 Main St.",|
              alpha_line %|-   "city" => "Oakland",|
              beta_line %|+   "city" => "Hill Valley",|
              plain_line %|    "state" => "CA",|
              alpha_line %|-   "zip" => "91234"|
              beta_line %|+   "zip" => "90382"|
              plain_line %|  }>|
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end
  end

  describe "and RSpec's #match matcher" do
    context "when the actual value is a HashWithIndifferentAccess" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = {
              line_1: "123 Main St.",
              city: "Hill Valley",
              state: "CA",
              zip: "90382",
            }
            actual = HashWithIndifferentAccess.new({
              line_1: "456 Ponderosa Ct.",
              city: "Oakland",
              state: "CA",
              zip: "91234",
            })
            expect(actual).to match(expected)
          TEST
          program = make_rspec_rails_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to match(expected)",
            expectation: proc {
              line do
                plain "Expected "
                beta %|#<HashWithIndifferentAccess { "line_1" => "456 Ponderosa Ct.", "city" => "Oakland", "state" => "CA", "zip" => "91234" }>|
              end

              line do
                plain "to match "
                alpha %|{ line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" }|
              end
            },
            diff: proc {
              plain_line %|  #<HashWithIndifferentAccess {|
              alpha_line %|-   "line_1" => "123 Main St.",|
              beta_line %|+   "line_1" => "456 Ponderosa Ct.",|
              alpha_line %|-   "city" => "Hill Valley",|
              beta_line %|+   "city" => "Oakland",|
              plain_line %|    "state" => "CA",|
              alpha_line %|-   "zip" => "90382"|
              beta_line %|+   "zip" => "91234"|
              plain_line %|  }>|
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end

    context "when the expected value is a HashWithIndifferentAccess" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = HashWithIndifferentAccess.new({
              line_1: "456 Ponderosa Ct.",
              city: "Oakland",
              state: "CA",
              zip: "91234",
            })
            actual = {
              line_1: "123 Main St.",
              city: "Hill Valley",
              state: "CA",
              zip: "90382",
            }
            expect(actual).to match(expected)
          TEST
          program = make_rspec_rails_test_program(
            snippet,
            color_enabled: color_enabled,
          )

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to match(expected)",
            expectation: proc {
              line do
                plain "Expected "
                beta %|{ line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" }|
              end

              line do
                plain "to match "
                alpha %|#<HashWithIndifferentAccess { "line_1" => "456 Ponderosa Ct.", "city" => "Oakland", "state" => "CA", "zip" => "91234" }>|
              end
            },
            diff: proc {
              plain_line %|  #<HashWithIndifferentAccess {|
              alpha_line %|-   "line_1" => "456 Ponderosa Ct.",|
              beta_line %|+   "line_1" => "123 Main St.",|
              alpha_line %|-   "city" => "Oakland",|
              beta_line %|+   "city" => "Hill Valley",|
              plain_line %|    "state" => "CA",|
              alpha_line %|-   "zip" => "91234"|
              beta_line %|+   "zip" => "90382"|
              plain_line %|  }>|
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end
  end
end
