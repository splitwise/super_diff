shared_examples_for "integration with ActiveRecord" do
  describe "and RSpec's #eq matcher" do
    context "when comparing two instances of the same ActiveRecord model" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = SuperDiff::Test::Models::ActiveRecord::ShippingAddress.new(
              line_1: "123 Main St.",
              city: "Hill Valley",
              state: "CA",
              zip: "90382",
            )
            actual = SuperDiff::Test::Models::ActiveRecord::ShippingAddress.new(
              line_1: "456 Ponderosa Ct.",
              city: "Oakland",
              state: "CA",
              zip: "91234",
            )
            expect(actual).to eq(expected)
          TEST
          program = make_program(snippet, color_enabled: color_enabled)

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to eq(expected)",
            expectation: proc {
              line do
                plain "Expected "
                green %|#<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: nil, city: "Oakland", line_1: "456 Ponderosa Ct.", line_2: "", state: "CA", zip: "91234">|
              end

              line do
                plain "   to eq "
                red   %|#<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: nil, city: "Hill Valley", line_1: "123 Main St.", line_2: "", state: "CA", zip: "90382">|
              end
            },
            diff: proc {
              plain_line %|  #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress {|
              plain_line %|    id: nil,|
              red_line   %|-   city: "Hill Valley",|
              green_line %|+   city: "Oakland",|
              red_line   %|-   line_1: "123 Main St.",|
              green_line %|+   line_1: "456 Ponderosa Ct.",|
              plain_line %|    line_2: "",|
              plain_line %|    state: "CA",|
              red_line   %|-   zip: "90382"|
              green_line %|+   zip: "91234"|
              plain_line %|  }>|
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end

    context "when comparing instances of two different ActiveRecord models" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = SuperDiff::Test::Models::ActiveRecord::ShippingAddress.new(
              line_1: "123 Main St.",
              city: "Hill Valley",
              state: "CA",
              zip: "90382",
            )
            actual = SuperDiff::Test::Models::ActiveRecord::Person.new(
              name: "Elliot",
              age: 31,
            )
            expect(actual).to eq(expected)
          TEST
          program = make_program(snippet, color_enabled: color_enabled)

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to eq(expected)",
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "Expected "
                green %|#<SuperDiff::Test::Models::ActiveRecord::Person id: nil, age: 31, name: "Elliot">|
              end

              line do
                plain "   to eq "
                red   %|#<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: nil, city: "Hill Valley", line_1: "123 Main St.", line_2: "", state: "CA", zip: "90382">|
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end

    context "when comparing an ActiveRecord object with nothing" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = SuperDiff::Test::Models::ActiveRecord::ShippingAddress.new(
              line_1: "123 Main St.",
              city: "Hill Valley",
              state: "CA",
              zip: "90382"
            )
            actual = nil
            expect(actual).to eq(expected)
          TEST
          program = make_program(snippet, color_enabled: color_enabled)

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to eq(expected)",
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain "Expected "
                green %|nil|
              end

              line do
                plain "   to eq "
                red   %|#<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: nil, city: "Hill Valley", line_1: "123 Main St.", line_2: "", state: "CA", zip: "90382">|
              end
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end

    context "when comparing two data structures that contain two instances of the same ActiveRecord model" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = {
              name: "Marty McFly",
              shipping_address: SuperDiff::Test::Models::ActiveRecord::ShippingAddress.new(
                line_1: "123 Main St.",
                city: "Hill Valley",
                state: "CA",
                zip: "90382",
              )
            }
            actual = {
              name: "Marty McFly",
              shipping_address: SuperDiff::Test::Models::ActiveRecord::ShippingAddress.new(
                line_1: "456 Ponderosa Ct.",
                city: "Oakland",
                state: "CA",
                zip: "91234",
              )
            }
            expect(actual).to eq(expected)
          TEST
          program = make_program(snippet, color_enabled: color_enabled)

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to eq(expected)",
            expectation: proc {
              line do
                plain "Expected "
                green %|{ name: "Marty McFly", shipping_address: #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: nil, city: "Oakland", line_1: "456 Ponderosa Ct.", line_2: "", state: "CA", zip: "91234"> }|
              end

              line do
                plain "   to eq "
                red   %|{ name: "Marty McFly", shipping_address: #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: nil, city: "Hill Valley", line_1: "123 Main St.", line_2: "", state: "CA", zip: "90382"> }|
              end
            },
            diff: proc {
              plain_line %|  {|
              plain_line %|    name: "Marty McFly",|
              plain_line %|    shipping_address: #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress {|
              plain_line %|      id: nil,|
              red_line   %|-     city: "Hill Valley",|
              green_line %|+     city: "Oakland",|
              red_line   %|-     line_1: "123 Main St.",|
              green_line %|+     line_1: "456 Ponderosa Ct.",|
              plain_line %|      line_2: "",|
              plain_line %|      state: "CA",|
              red_line   %|-     zip: "90382"|
              green_line %|+     zip: "91234"|
              plain_line %|    }>|
              plain_line %|  }|
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end

    context "when comparing two data structures that contain instances of two different ActiveRecord models" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            expected = {
              name: "Marty McFly",
              shipping_address: SuperDiff::Test::Models::ActiveRecord::ShippingAddress.new(
                line_1: "123 Main St.",
                city: "Hill Valley",
                state: "CA",
                zip: "90382",
              )
            }
            actual = {
              name: "Marty McFly",
              shipping_address: SuperDiff::Test::Models::ActiveRecord::Person.new(
                name: "Elliot",
                age: 31,
              )
            }
            expect(actual).to eq(expected)
          TEST
          program = make_program(snippet, color_enabled: color_enabled)

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to eq(expected)",
            expectation: proc {
              line do
                plain "Expected "
                green %|{ name: "Marty McFly", shipping_address: #<SuperDiff::Test::Models::ActiveRecord::Person id: nil, age: 31, name: "Elliot"> }|
              end

              line do
                plain "   to eq "
                red   %|{ name: "Marty McFly", shipping_address: #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: nil, city: "Hill Valley", line_1: "123 Main St.", line_2: "", state: "CA", zip: "90382"> }|
              end
            },
            diff: proc {
              plain_line %|  {|
              plain_line %|    name: "Marty McFly",|
              red_line   %|-   shipping_address: #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress {|
              red_line   %|-     id: nil,|
              red_line   %|-     city: "Hill Valley",|
              red_line   %|-     line_1: "123 Main St.",|
              red_line   %|-     line_2: "",|
              red_line   %|-     state: "CA",|
              red_line   %|-     zip: "90382"|
              red_line   %|-   }>|
              green_line %|+   shipping_address: #<SuperDiff::Test::Models::ActiveRecord::Person {|
              green_line %|+     id: nil,|
              green_line %|+     age: 31,|
              green_line %|+     name: "Elliot"|
              green_line %|+   }>|
              plain_line %|  }|
            },
          )

          expect(program).
            to produce_output_when_run(expected_output).
            in_color(color_enabled)
        end
      end
    end

    context "when comparing an ActiveRecord::Relation object with an array" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            SuperDiff::Test::Models::ActiveRecord::ShippingAddress.delete_all
            shipping_addresses = [
              SuperDiff::Test::Models::ActiveRecord::ShippingAddress.create!(
                line_1: "123 Main St.",
                city: "Hill Valley",
                state: "CA",
                zip: "90382",
              ),
              SuperDiff::Test::Models::ActiveRecord::ShippingAddress.create!(
                line_1: "456 Ponderosa Ct.",
                city: "Oakland",
                state: "CA",
                zip: "91234",
              )
            ]
            expected = [shipping_addresses.first]
            actual = SuperDiff::Test::Models::ActiveRecord::ShippingAddress.all
            expect(actual).to eq(expected)
          TEST
          program = make_program(snippet, color_enabled: color_enabled)

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to eq(expected)",
            expectation: proc {
              line do
                plain "Expected "
                green %|#<ActiveRecord::Relation [#<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: 1, city: "Hill Valley", line_1: "123 Main St.", line_2: "", state: "CA", zip: "90382">, #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: 2, city: "Oakland", line_1: "456 Ponderosa Ct.", line_2: "", state: "CA", zip: "91234">]>|
              end

              line do
                plain "   to eq "
                red   %|[#<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: 1, city: "Hill Valley", line_1: "123 Main St.", line_2: "", state: "CA", zip: "90382">]|
              end
            },
            diff: proc {
              plain_line %|  #<ActiveRecord::Relation [|
              plain_line %|    #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress {|
              plain_line %|      id: 1,|
              plain_line %|      city: "Hill Valley",|
              plain_line %|      line_1: "123 Main St.",|
              plain_line %|      line_2: "",|
              plain_line %|      state: "CA",|
              plain_line %|      zip: "90382"|
              plain_line %|    }>,|
              green_line %|+   #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress {|
              green_line %|+     id: 2,|
              green_line %|+     city: "Oakland",|
              green_line %|+     line_1: "456 Ponderosa Ct.",|
              green_line %|+     line_2: "",|
              green_line %|+     state: "CA",|
              green_line %|+     zip: "91234"|
              green_line %|+   }>|
              plain_line %|  ]>|
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
