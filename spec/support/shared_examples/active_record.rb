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
            actual   = SuperDiff::Test::Models::ActiveRecord::ShippingAddress.new(
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
                plain    %|Expected |
                actual   %|#<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: nil, city: "Oakland", line_1: "456 Ponderosa Ct.", line_2: "", state: "CA", zip: "91234">|
              end

              line do
                plain    %|   to eq |
                expected %|#<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: nil, city: "Hill Valley", line_1: "123 Main St.", line_2: "", state: "CA", zip: "90382">|
              end
            },
            diff: proc {
              plain_line    %|  #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress {|
              plain_line    %|    id: nil,|
              expected_line %|-   city: "Hill Valley",|
              actual_line   %|+   city: "Oakland",|
              expected_line %|-   line_1: "123 Main St.",|
              actual_line   %|+   line_1: "456 Ponderosa Ct.",|
              plain_line    %|    line_2: "",|
              plain_line    %|    state: "CA",|
              expected_line %|-   zip: "90382"|
              actual_line   %|+   zip: "91234"|
              plain_line    %|  }>|
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
            actual   = SuperDiff::Test::Models::ActiveRecord::Person.new(
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
                plain    %|Expected |
                actual   %|#<SuperDiff::Test::Models::ActiveRecord::Person id: nil, age: 31, name: "Elliot">|
              end

              line do
                plain    %|   to eq |
                expected %|#<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: nil, city: "Hill Valley", line_1: "123 Main St.", line_2: "", state: "CA", zip: "90382">|
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
            actual   = nil
            expect(actual).to eq(expected)
          TEST
          program = make_program(snippet, color_enabled: color_enabled)

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to eq(expected)",
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain    %|Expected |
                actual   %|nil|
              end

              line do
                plain    %|   to eq |
                expected %|#<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: nil, city: "Hill Valley", line_1: "123 Main St.", line_2: "", state: "CA", zip: "90382">|
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
            actual   = {
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
                plain    %|Expected |
                actual   %|{ name: "Marty McFly", shipping_address: #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: nil, city: "Oakland", line_1: "456 Ponderosa Ct.", line_2: "", state: "CA", zip: "91234"> }|
              end

              line do
                plain    %|   to eq |
                expected %|{ name: "Marty McFly", shipping_address: #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: nil, city: "Hill Valley", line_1: "123 Main St.", line_2: "", state: "CA", zip: "90382"> }|
              end
            },
            diff: proc {
              plain_line    %|  {|
              plain_line    %|    name: "Marty McFly",|
              plain_line    %|    shipping_address: #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress {|
              plain_line    %|      id: nil,|
              expected_line %|-     city: "Hill Valley",|
              actual_line   %|+     city: "Oakland",|
              expected_line %|-     line_1: "123 Main St.",|
              actual_line   %|+     line_1: "456 Ponderosa Ct.",|
              plain_line    %|      line_2: "",|
              plain_line    %|      state: "CA",|
              expected_line %|-     zip: "90382"|
              actual_line   %|+     zip: "91234"|
              plain_line    %|    }>|
              plain_line    %|  }|
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
            actual   = {
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
                plain    %|Expected |
                actual   %|{ name: "Marty McFly", shipping_address: #<SuperDiff::Test::Models::ActiveRecord::Person id: nil, age: 31, name: "Elliot"> }|
              end

              line do
                plain    %|   to eq |
                expected %|{ name: "Marty McFly", shipping_address: #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: nil, city: "Hill Valley", line_1: "123 Main St.", line_2: "", state: "CA", zip: "90382"> }|
              end
            },
            diff: proc {
              plain_line    %|  {|
              plain_line    %|    name: "Marty McFly",|
              expected_line %|-   shipping_address: #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress {|
              expected_line %|-     id: nil,|
              expected_line %|-     city: "Hill Valley",|
              expected_line %|-     line_1: "123 Main St.",|
              expected_line %|-     line_2: "",|
              expected_line %|-     state: "CA",|
              expected_line %|-     zip: "90382"|
              expected_line %|-   }>|
              actual_line   %|+   shipping_address: #<SuperDiff::Test::Models::ActiveRecord::Person {|
              actual_line   %|+     id: nil,|
              actual_line   %|+     age: 31,|
              actual_line   %|+     name: "Elliot"|
              actual_line   %|+   }>|
              plain_line    %|  }|
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
            actual   = SuperDiff::Test::Models::ActiveRecord::ShippingAddress.all
            expect(actual).to eq(expected)
          TEST
          program = make_program(snippet, color_enabled: color_enabled)

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: "expect(actual).to eq(expected)",
            expectation: proc {
              line do
                plain    %|Expected |
                actual   %|#<ActiveRecord::Relation [#<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: 1, city: "Hill Valley", line_1: "123 Main St.", line_2: "", state: "CA", zip: "90382">, #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: 2, city: "Oakland", line_1: "456 Ponderosa Ct.", line_2: "", state: "CA", zip: "91234">]>|
              end

              line do
                plain    %|   to eq |
                expected %|[#<SuperDiff::Test::Models::ActiveRecord::ShippingAddress id: 1, city: "Hill Valley", line_1: "123 Main St.", line_2: "", state: "CA", zip: "90382">]|
              end
            },
            diff: proc {
              plain_line    %|  #<ActiveRecord::Relation [|
              plain_line    %|    #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress {|
              plain_line    %|      id: 1,|
              plain_line    %|      city: "Hill Valley",|
              plain_line    %|      line_1: "123 Main St.",|
              plain_line    %|      line_2: "",|
              plain_line    %|      state: "CA",|
              plain_line    %|      zip: "90382"|
              plain_line    %|    }>,|
              actual_line   %|+   #<SuperDiff::Test::Models::ActiveRecord::ShippingAddress {|
              actual_line   %|+     id: 2,|
              actual_line   %|+     city: "Oakland",|
              actual_line   %|+     line_1: "456 Ponderosa Ct.",|
              actual_line   %|+     line_2: "",|
              actual_line   %|+     state: "CA",|
              actual_line   %|+     zip: "91234"|
              actual_line   %|+   }>|
              plain_line    %|  ]>|
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
    context "when the expected value includes an ActiveRecord object" do
      it "produces the correct output" do
        as_both_colored_and_uncolored do |color_enabled|
          snippet = <<~TEST.strip
            SuperDiff::Test::Models::ActiveRecord::Person.create!(
              name: "Murphy",
              age: 20
            )

            expected = [
              an_object_having_attributes(
                results: [
                  an_object_having_attributes(name: "John", age: 19)
                ]
              )
            ]

            actual   = [
              SuperDiff::Test::Models::ActiveRecord::Query.new(
                results: SuperDiff::Test::Models::ActiveRecord::Person.all
              )
            ]

            expect(actual).to match(expected)
          TEST

          program = make_program(snippet, color_enabled: color_enabled)

          expected_output = build_expected_output(
            color_enabled: color_enabled,
            snippet: %|expect(actual).to match(expected)|,
            newline_before_expectation: true,
            expectation: proc {
              line do
                plain    %|Expected |
                actual   %|[#<SuperDiff::Test::Models::ActiveRecord::Query @results=#<ActiveRecord::Relation [#<SuperDiff::Test::Models::ActiveRecord::Person id: 1, age: 20, name: "Murphy">]>>]|
              end

              line do
                plain    %|to match |
                expected %|[#<an object having attributes (results: [#<an object having attributes (name: "John", age: 19)>])>]|
              end
            },
            diff: proc {
              plain_line    %|  [|
              plain_line    %|    #<SuperDiff::Test::Models::ActiveRecord::Query {|
              plain_line    %|      @results=#<ActiveRecord::Relation [|
              plain_line    %|        #<SuperDiff::Test::Models::ActiveRecord::Person {|
              plain_line    %|          id: 1,|
              # expected_line %|-         age: 19,|  # TODO
              expected_line %|-         age: 19|
              actual_line   %|+         age: 20,|
              # expected_line %|-         name: "John"|  # TODO
              expected_line %|-         name: "John",|
              actual_line   %|+         name: "Murphy"|
              plain_line    %|        }>|
              plain_line    %|      ]>|
              plain_line    %|    }>|
              plain_line    %|  ]|
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
