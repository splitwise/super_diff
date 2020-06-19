shared_examples_for "integration with HashWithIndifferentAccess" do
  describe "and RSpec's #eq matcher" do
    context "when the actual   value is a HashWithIndifferentAccess" do
      context "and both hashes are one-dimensional" do
        context "and the expected hash contains symbol keys" do
          it "produces the correct output" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expected = {
                  line_1: "123 Main St.",
                  city: "Hill Valley",
                  state: "CA",
                  zip: "90382",
                }
                actual   = HashWithIndifferentAccess.new({
                  line_1: "456 Ponderosa Ct.",
                  city: "Oakland",
                  state: "CA",
                  zip: "91234",
                })
                expect(actual).to eq(expected)
              TEST
              program = make_program(snippet, color_enabled: color_enabled)

              expected_output = build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(actual).to eq(expected)",
                expectation: proc {
                  line do
                    plain    %|Expected |
                    actual   %|#<HashWithIndifferentAccess { "line_1" => "456 Ponderosa Ct.", "city" => "Oakland", "state" => "CA", "zip" => "91234" }>|
                  end

                  line do
                    plain    %|   to eq |
                    expected %|{ line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" }|
                  end
                },
                diff: proc {
                  plain_line    %|  #<HashWithIndifferentAccess {|
                  expected_line %|-   "line_1" => "123 Main St.",|
                  actual_line   %|+   "line_1" => "456 Ponderosa Ct.",|
                  expected_line %|-   "city" => "Hill Valley",|
                  actual_line   %|+   "city" => "Oakland",|
                  plain_line    %|    "state" => "CA",|
                  expected_line %|-   "zip" => "90382"|
                  actual_line   %|+   "zip" => "91234"|
                  plain_line    %|  }>|
                },
              )

              expect(program).
                to produce_output_when_run(expected_output).
                in_color(color_enabled)
            end
          end
        end

        context "and the expected hash contains string keys" do
          it "produces the correct output" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expected = {
                  "line_1" => "123 Main St.",
                  "city" => "Hill Valley",
                  "state" => "CA",
                  "zip" => "90382",
                }
                actual   = HashWithIndifferentAccess.new({
                  line_1: "456 Ponderosa Ct.",
                  city: "Oakland",
                  state: "CA",
                  zip: "91234",
                })
                expect(actual).to eq(expected)
              TEST
              program = make_program(snippet, color_enabled: color_enabled)

              expected_output = build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(actual).to eq(expected)",
                expectation: proc {
                  line do
                    plain    %|Expected |
                    actual   %|#<HashWithIndifferentAccess { "line_1" => "456 Ponderosa Ct.", "city" => "Oakland", "state" => "CA", "zip" => "91234" }>|
                  end

                  line do
                    plain    %|   to eq |
                    expected %|{ "line_1" => "123 Main St.", "city" => "Hill Valley", "state" => "CA", "zip" => "90382" }|
                  end
                },
                diff: proc {
                  plain_line    %|  #<HashWithIndifferentAccess {|
                  expected_line %|-   "line_1" => "123 Main St.",|
                  actual_line   %|+   "line_1" => "456 Ponderosa Ct.",|
                  expected_line %|-   "city" => "Hill Valley",|
                  actual_line   %|+   "city" => "Oakland",|
                  plain_line    %|    "state" => "CA",|
                  expected_line %|-   "zip" => "90382"|
                  actual_line   %|+   "zip" => "91234"|
                  plain_line    %|  }>|
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

    context "when the expected value is a HashWithIndifferentAccess" do
      context "and both hashes are one-dimensional" do
        context "and the actual hash contains symbol keys" do
          it "produces the correct output" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expected = HashWithIndifferentAccess.new({
                  line_1: "456 Ponderosa Ct.",
                  city: "Oakland",
                  state: "CA",
                  zip: "91234",
                })
                actual   = {
                  line_1: "123 Main St.",
                  city: "Hill Valley",
                  state: "CA",
                  zip: "90382",
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
                    actual   %|{ line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" }|
                  end

                  line do
                    plain    %|   to eq |
                    expected %|#<HashWithIndifferentAccess { "line_1" => "456 Ponderosa Ct.", "city" => "Oakland", "state" => "CA", "zip" => "91234" }>|
                  end
                },
                diff: proc {
                  plain_line    %|  #<HashWithIndifferentAccess {|
                  expected_line %|-   "line_1" => "456 Ponderosa Ct.",|
                  actual_line   %|+   "line_1" => "123 Main St.",|
                  expected_line %|-   "city" => "Oakland",|
                  actual_line   %|+   "city" => "Hill Valley",|
                  plain_line    %|    "state" => "CA",|
                  expected_line %|-   "zip" => "91234"|
                  actual_line   %|+   "zip" => "90382"|
                  plain_line    %|  }>|
                },
              )

              expect(program).
                to produce_output_when_run(expected_output).
                in_color(color_enabled)
            end
          end
        end

        context "and the actual   hash contains string keys" do
          it "produces the correct output" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expected = HashWithIndifferentAccess.new({
                  line_1: "456 Ponderosa Ct.",
                  city: "Oakland",
                  state: "CA",
                  zip: "91234",
                })
                actual   = {
                  "line_1" => "123 Main St.",
                  "city" => "Hill Valley",
                  "state" => "CA",
                  "zip" => "90382",
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
                    actual   %|{ "line_1" => "123 Main St.", "city" => "Hill Valley", "state" => "CA", "zip" => "90382" }|
                  end

                  line do
                    plain    %|   to eq |
                    expected %|#<HashWithIndifferentAccess { "line_1" => "456 Ponderosa Ct.", "city" => "Oakland", "state" => "CA", "zip" => "91234" }>|
                  end
                },
                diff: proc {
                  plain_line    %|  #<HashWithIndifferentAccess {|
                  expected_line %|-   "line_1" => "456 Ponderosa Ct.",|
                  actual_line   %|+   "line_1" => "123 Main St.",|
                  expected_line %|-   "city" => "Oakland",|
                  actual_line   %|+   "city" => "Hill Valley",|
                  plain_line    %|    "state" => "CA",|
                  expected_line %|-   "zip" => "91234"|
                  actual_line   %|+   "zip" => "90382"|
                  plain_line    %|  }>|
                },
              )

              expect(program).
                to produce_output_when_run(expected_output).
                in_color(color_enabled)
            end
          end
        end
      end

      context "and both hashes are multi-dimensional" do
        context "and the actual hash contains symbol keys" do
          it "produces the correct output" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expected = HashWithIndifferentAccess.new({
                  shipments: [
                    HashWithIndifferentAccess.new({
                      estimated_delivery: HashWithIndifferentAccess.new({
                        from: '2019-05-06',
                        to: '2019-05-06'
                      })
                    })
                  ]
                })
                actual   = {
                  shipments: [
                    {
                      estimated_delivery: {
                        from: '2019-05-06',
                        to: '2019-05-09'
                      }
                    }
                  ]
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
                    actual   %|{ shipments: [{ estimated_delivery: { from: "2019-05-06", to: "2019-05-09" } }] }|
                  end

                  line do
                    plain    %|   to eq |
                    expected %|#<HashWithIndifferentAccess { "shipments" => [#<HashWithIndifferentAccess { "estimated_delivery" => #<HashWithIndifferentAccess { "from" => "2019-05-06", "to" => "2019-05-06" }> }>] }>|
                  end
                },
                diff: proc {
                  plain_line    %|  #<HashWithIndifferentAccess {|
                  plain_line    %|    "shipments" => [|
                  plain_line    %|      #<HashWithIndifferentAccess {|
                  plain_line    %|        "estimated_delivery" => #<HashWithIndifferentAccess {|
                  plain_line    %|          "from" => "2019-05-06",|
                  expected_line %|-         "to" => "2019-05-06"|
                  actual_line   %|+         "to" => "2019-05-09"|
                  plain_line    %|        }>|
                  plain_line    %|      }>|
                  plain_line    %|    ]|
                  plain_line    %|  }>|
                },
              )

              expect(program).
                to produce_output_when_run(expected_output).
                in_color(color_enabled)
            end
          end
        end

        context "and the actual   hash contains string keys" do
          it "produces the correct output" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expected = HashWithIndifferentAccess.new({
                  shipments: [
                    HashWithIndifferentAccess.new({
                      estimated_delivery: HashWithIndifferentAccess.new({
                        from: '2019-05-06',
                        to: '2019-05-06'
                      })
                    })
                  ]
                })
                actual   = {
                  'shipments' => [
                    {
                      'estimated_delivery' => {
                        'from' => '2019-05-06',
                        'to' => '2019-05-09'
                      }
                    }
                  ]
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
                    actual   %|{ "shipments" => [{ "estimated_delivery" => { "from" => "2019-05-06", "to" => "2019-05-09" } }] }|
                  end

                  line do
                    plain    %|   to eq |
                    expected %|#<HashWithIndifferentAccess { "shipments" => [#<HashWithIndifferentAccess { "estimated_delivery" => #<HashWithIndifferentAccess { "from" => "2019-05-06", "to" => "2019-05-06" }> }>] }>|
                  end
                },
                diff: proc {
                  plain_line    %|  #<HashWithIndifferentAccess {|
                  plain_line    %|    "shipments" => [|
                  plain_line    %|      #<HashWithIndifferentAccess {|
                  plain_line    %|        "estimated_delivery" => #<HashWithIndifferentAccess {|
                  plain_line    %|          "from" => "2019-05-06",|
                  expected_line %|-         "to" => "2019-05-06"|
                  actual_line   %|+         "to" => "2019-05-09"|
                  plain_line    %|        }>|
                  plain_line    %|      }>|
                  plain_line    %|    ]|
                  plain_line    %|  }>|
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
  end

  describe "and RSpec's #match matcher" do
    context "when the actual   value is a HashWithIndifferentAccess" do
      context "and both hashes are one-dimensional" do
        context "and the expected hash contains symbol keys" do
          it "produces the correct output" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expected = {
                  line_1: "123 Main St.",
                  city: "Hill Valley",
                  state: "CA",
                  zip: "90382",
                }
                actual   = HashWithIndifferentAccess.new({
                  line_1: "456 Ponderosa Ct.",
                  city: "Oakland",
                  state: "CA",
                  zip: "91234",
                })
                expect(actual).to match(expected)
              TEST
              program = make_program(snippet, color_enabled: color_enabled)

              expected_output = build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(actual).to match(expected)",
                expectation: proc {
                  line do
                    plain    %|Expected |
                    actual   %|#<HashWithIndifferentAccess { "line_1" => "456 Ponderosa Ct.", "city" => "Oakland", "state" => "CA", "zip" => "91234" }>|
                  end

                  line do
                    plain    %|to match |
                    expected %|{ line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" }|
                  end
                },
                diff: proc {
                  plain_line    %|  #<HashWithIndifferentAccess {|
                  expected_line %|-   "line_1" => "123 Main St.",|
                  actual_line   %|+   "line_1" => "456 Ponderosa Ct.",|
                  expected_line %|-   "city" => "Hill Valley",|
                  actual_line   %|+   "city" => "Oakland",|
                  plain_line    %|    "state" => "CA",|
                  expected_line %|-   "zip" => "90382"|
                  actual_line   %|+   "zip" => "91234"|
                  plain_line    %|  }>|
                },
              )

              expect(program).
                to produce_output_when_run(expected_output).
                in_color(color_enabled)
            end
          end
        end

        context "and the expected hash contains string keys" do
          it "produces the correct output" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expected = {
                  "line_1" => "123 Main St.",
                  "city" => "Hill Valley",
                  "state" => "CA",
                  "zip" => "90382",
                }
                actual   = HashWithIndifferentAccess.new({
                  line_1: "456 Ponderosa Ct.",
                  city: "Oakland",
                  state: "CA",
                  zip: "91234",
                })
                expect(actual).to match(expected)
              TEST
              program = make_program(snippet, color_enabled: color_enabled)

              expected_output = build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(actual).to match(expected)",
                expectation: proc {
                  line do
                    plain    %|Expected |
                    actual   %|#<HashWithIndifferentAccess { "line_1" => "456 Ponderosa Ct.", "city" => "Oakland", "state" => "CA", "zip" => "91234" }>|
                  end

                  line do
                    plain    %|to match |
                    expected %|{ "line_1" => "123 Main St.", "city" => "Hill Valley", "state" => "CA", "zip" => "90382" }|
                  end
                },
                diff: proc {
                  plain_line    %|  #<HashWithIndifferentAccess {|
                  expected_line %|-   "line_1" => "123 Main St.",|
                  actual_line   %|+   "line_1" => "456 Ponderosa Ct.",|
                  expected_line %|-   "city" => "Hill Valley",|
                  actual_line   %|+   "city" => "Oakland",|
                  plain_line    %|    "state" => "CA",|
                  expected_line %|-   "zip" => "90382"|
                  actual_line   %|+   "zip" => "91234"|
                  plain_line    %|  }>|
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

    context "when the expected value is a HashWithIndifferentAccess" do
      context "and both hashes are one-dimensional" do
        context "and the actual   hash contains symbol keys" do
          it "produces the correct output" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expected = HashWithIndifferentAccess.new({
                  line_1: "456 Ponderosa Ct.",
                  city: "Oakland",
                  state: "CA",
                  zip: "91234",
                })
                actual   = {
                  line_1: "123 Main St.",
                  city: "Hill Valley",
                  state: "CA",
                  zip: "90382",
                }
                expect(actual).to match(expected)
              TEST
              program = make_program(snippet, color_enabled: color_enabled)

              expected_output = build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(actual).to match(expected)",
                expectation: proc {
                  line do
                    plain    %|Expected |
                    actual   %|{ line_1: "123 Main St.", city: "Hill Valley", state: "CA", zip: "90382" }|
                  end

                  line do
                    plain    %|to match |
                    expected %|#<HashWithIndifferentAccess { "line_1" => "456 Ponderosa Ct.", "city" => "Oakland", "state" => "CA", "zip" => "91234" }>|
                  end
                },
                diff: proc {
                  plain_line    %|  #<HashWithIndifferentAccess {|
                  expected_line %|-   "line_1" => "456 Ponderosa Ct.",|
                  actual_line   %|+   "line_1" => "123 Main St.",|
                  expected_line %|-   "city" => "Oakland",|
                  actual_line   %|+   "city" => "Hill Valley",|
                  plain_line    %|    "state" => "CA",|
                  expected_line %|-   "zip" => "91234"|
                  actual_line   %|+   "zip" => "90382"|
                  plain_line    %|  }>|
                },
              )

              expect(program).
                to produce_output_when_run(expected_output).
                in_color(color_enabled)
            end
          end
        end

        context "and the actual   hash contains string keys" do
          it "produces the correct output" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expected = HashWithIndifferentAccess.new({
                  line_1: "456 Ponderosa Ct.",
                  city: "Oakland",
                  state: "CA",
                  zip: "91234",
                })
                actual   = {
                  "line_1" => "123 Main St.",
                  "city" => "Hill Valley",
                  "state" => "CA",
                  "zip" => "90382",
                }
                expect(actual).to match(expected)
              TEST
              program = make_program(snippet, color_enabled: color_enabled)

              expected_output = build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(actual).to match(expected)",
                expectation: proc {
                  line do
                    plain    %|Expected |
                    actual   %|{ "line_1" => "123 Main St.", "city" => "Hill Valley", "state" => "CA", "zip" => "90382" }|
                  end

                  line do
                    plain    %|to match |
                    expected %|#<HashWithIndifferentAccess { "line_1" => "456 Ponderosa Ct.", "city" => "Oakland", "state" => "CA", "zip" => "91234" }>|
                  end
                },
                diff: proc {
                  plain_line    %|  #<HashWithIndifferentAccess {|
                  expected_line %|-   "line_1" => "456 Ponderosa Ct.",|
                  actual_line   %|+   "line_1" => "123 Main St.",|
                  expected_line %|-   "city" => "Oakland",|
                  actual_line   %|+   "city" => "Hill Valley",|
                  plain_line    %|    "state" => "CA",|
                  expected_line %|-   "zip" => "91234"|
                  actual_line   %|+   "zip" => "90382"|
                  plain_line    %|  }>|
                },
              )

              expect(program).
                to produce_output_when_run(expected_output).
                in_color(color_enabled)
            end
          end
        end
      end

      context "and both hashes are multi-dimensional" do
        context "and the actual   hash contains symbol keys" do
          it "produces the correct output" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expected = HashWithIndifferentAccess.new({
                  shipments: [
                    HashWithIndifferentAccess.new({
                      estimated_delivery: HashWithIndifferentAccess.new({
                        from: '2019-05-06',
                        to: '2019-05-06'
                      })
                    })
                  ]
                })
                actual   = {
                  shipments: [
                    {
                      estimated_delivery: {
                        from: '2019-05-06',
                        to: '2019-05-09'
                      }
                    }
                  ]
                }
                expect(actual).to match(expected)
              TEST
              program = make_program(snippet, color_enabled: color_enabled)

              expected_output = build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(actual).to match(expected)",
                expectation: proc {
                  line do
                    plain    %|Expected |
                    actual   %|{ shipments: [{ estimated_delivery: { from: "2019-05-06", to: "2019-05-09" } }] }|
                  end

                  line do
                    plain    %|to match |
                    expected %|#<HashWithIndifferentAccess { "shipments" => [#<HashWithIndifferentAccess { "estimated_delivery" => #<HashWithIndifferentAccess { "from" => "2019-05-06", "to" => "2019-05-06" }> }>] }>|
                  end
                },
                diff: proc {
                  plain_line    %|  #<HashWithIndifferentAccess {|
                  plain_line    %|    "shipments" => [|
                  plain_line    %|      #<HashWithIndifferentAccess {|
                  plain_line    %|        "estimated_delivery" => #<HashWithIndifferentAccess {|
                  plain_line    %|          "from" => "2019-05-06",|
                  expected_line %|-         "to" => "2019-05-06"|
                  actual_line   %|+         "to" => "2019-05-09"|
                  plain_line    %|        }>|
                  plain_line    %|      }>|
                  plain_line    %|    ]|
                  plain_line    %|  }>|
                },
              )

              expect(program).
                to produce_output_when_run(expected_output).
                in_color(color_enabled)
            end
          end
        end

        context "and the actual   hash contains string keys" do
          it "produces the correct output" do
            as_both_colored_and_uncolored do |color_enabled|
              snippet = <<~TEST.strip
                expected = HashWithIndifferentAccess.new({
                  shipments: [
                    HashWithIndifferentAccess.new({
                      estimated_delivery: HashWithIndifferentAccess.new({
                        from: '2019-05-06',
                        to: '2019-05-06'
                      })
                    })
                  ]
                })
                actual   = {
                  'shipments' => [
                    {
                      'estimated_delivery' => {
                        'from' => '2019-05-06',
                        'to' => '2019-05-09'
                      }
                    }
                  ]
                }
                expect(actual).to match(expected)
              TEST
              program = make_program(snippet, color_enabled: color_enabled)

              expected_output = build_expected_output(
                color_enabled: color_enabled,
                snippet: "expect(actual).to match(expected)",
                expectation: proc {
                  line do
                    plain    %|Expected |
                    actual   %|{ "shipments" => [{ "estimated_delivery" => { "from" => "2019-05-06", "to" => "2019-05-09" } }] }|
                  end

                  line do
                    plain    %|to match |
                    expected %|#<HashWithIndifferentAccess { "shipments" => [#<HashWithIndifferentAccess { "estimated_delivery" => #<HashWithIndifferentAccess { "from" => "2019-05-06", "to" => "2019-05-06" }> }>] }>|
                  end
                },
                diff: proc {
                  plain_line    %|  #<HashWithIndifferentAccess {|
                  plain_line    %|    "shipments" => [|
                  plain_line    %|      #<HashWithIndifferentAccess {|
                  plain_line    %|        "estimated_delivery" => #<HashWithIndifferentAccess {|
                  plain_line    %|          "from" => "2019-05-06",|
                  expected_line %|-         "to" => "2019-05-06"|
                  actual_line   %|+         "to" => "2019-05-09"|
                  plain_line    %|        }>|
                  plain_line    %|      }>|
                  plain_line    %|    ]|
                  plain_line    %|  }>|
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
  end
end
