require "spec_helper"

RSpec.describe SuperDiff, type: :unit do
  describe ".inspect_object", "for Ruby objects" do
    context "given nil" do
      context "given as_lines: false" do
        it "returns 'nil'" do
          string = described_class.inspect_object(nil, as_lines: false)
          expect(string).to eq("nil")
        end
      end

      context "given as_lines: true" do
        it "returns nil wrapped in a single Line" do
          tiered_lines =
            described_class.inspect_object(
              nil,
              as_lines: true,
              type: :delete,
              indentation_level: 1
            )
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: "nil"
              )
            ]
          )
        end
      end
    end

    context "given true" do
      context "given as_lines: false" do
        it "returns an inspected version of true" do
          string = described_class.inspect_object(true, as_lines: false)
          expect(string).to eq("true")
        end
      end

      context "given as_lines: true" do
        it "returns true wrapped in a single Line" do
          tiered_lines =
            described_class.inspect_object(
              true,
              as_lines: true,
              type: :delete,
              indentation_level: 1
            )
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: "true"
              )
            ]
          )
        end
      end
    end

    context "given false" do
      context "given as_lines: false" do
        it "returns an inspected version of false" do
          string = described_class.inspect_object(false, as_lines: false)
          expect(string).to eq("false")
        end
      end

      context "given as_lines: true" do
        it "returns false wrapped in a single Line" do
          tiered_lines =
            described_class.inspect_object(
              false,
              as_lines: true,
              type: :delete,
              indentation_level: 1
            )
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: "false"
              )
            ]
          )
        end
      end
    end

    context "given a number" do
      context "given as_lines: false" do
        it "returns an inspected version of the number" do
          string = described_class.inspect_object(3, as_lines: false)
          expect(string).to eq("3")
        end
      end

      context "given as_lines: true" do
        it "returns the number wrapped in a single Line" do
          tiered_lines =
            described_class.inspect_object(
              3,
              as_lines: true,
              type: :delete,
              indentation_level: 1
            )
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: "3"
              )
            ]
          )
        end
      end
    end

    context "given a symbol" do
      context "given as_lines: false" do
        it "returns an inspected version of the symbol" do
          string = described_class.inspect_object(:foo, as_lines: false)
          expect(string).to eq(":foo")
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the symbol wrapped in a single Line" do
          tiered_lines =
            described_class.inspect_object(
              :foo,
              as_lines: true,
              type: :delete,
              indentation_level: 1
            )
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: ":foo"
              )
            ]
          )
        end
      end
    end

    context "given a regex" do
      context "given as_lines: false" do
        it "returns an inspected version of the regex" do
          string = described_class.inspect_object(/foo/, as_lines: false)
          expect(string).to eq("/foo/")
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the regex wrapped in a single Line" do
          tiered_lines =
            described_class.inspect_object(
              /foo/,
              as_lines: true,
              type: :delete,
              indentation_level: 1
            )
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: "/foo/"
              )
            ]
          )
        end
      end
    end

    context "given a single-line string" do
      context "given as_lines: false" do
        it "returns an inspected version of the string" do
          inspection = described_class.inspect_object("Marty", as_lines: false)
          expect(inspection).to eq('"Marty"')
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the string wrapped in a single Line" do
          tiered_lines =
            described_class.inspect_object(
              "Marty",
              as_lines: true,
              type: :delete,
              indentation_level: 1
            )
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: %("Marty")
              )
            ]
          )
        end
      end
    end

    context "given a multi-line string" do
      context "that does not contain color codes" do
        context "given as_lines: false" do
          it "returns an inspected version of the string, with newline characters escaped" do
            string =
              described_class.inspect_object(
                "This is a line\nAnd that's a line\nAnd there's a line too",
                as_lines: false
              )
            expect(string).to eq(
              %("This is a line\\nAnd that's a line\\nAnd there's a line too")
            )
          end
        end

        context "given as_lines: true" do
          it "returns an inspected version of the string, with newline characters escaped, wrapped in a Line" do
            tiered_lines =
              described_class.inspect_object(
                "This is a line\nAnd that's a line\nAnd there's a line too",
                as_lines: true,
                type: :delete,
                indentation_level: 1
              )
            expect(tiered_lines).to match(
              [
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value:
                    %("This is a line\\nAnd that's a line\\nAnd there's a line too")
                )
              ]
            )
          end
        end
      end

      context "that contains color codes" do
        context "given as_lines: false" do
          it "returns an inspected version of string with the color codes escaped" do
            colors = [
              SuperDiff::Csi::FourBitColor.new(:blue, layer: :foreground),
              SuperDiff::Csi::EightBitColor.new(
                red: 3,
                green: 8,
                blue: 4,
                layer: :foreground
              ),
              SuperDiff::Csi::TwentyFourBitColor.new(
                red: 47,
                green: 164,
                blue: 59,
                layer: :foreground
              )
            ]
            string_to_inspect = [
              colored("This is a line", colors[0]),
              colored("And that's a line", colors[1]),
              colored("And there's a line too", colors[2])
            ].join("\n")

            inspection =
              described_class.inspect_object(string_to_inspect, as_lines: false)
            # TODO: Figure out how to represent a colorized string inside of an
            # already colorized string
            expect(inspection).to eq(
              %("\\e[34mThis is a line\\e[0m\\n\\e[38;5;176mAnd that's a line\\e[0m\\n\\e[38;2;47;59;164mAnd there's a line too\\e[0m")
            )
          end
        end

        context "given as_lines: true" do
          it "returns an inspected version of the string, with the color codes escaped, wrapped in a Line" do
            colors = [
              SuperDiff::Csi::FourBitColor.new(:blue, layer: :foreground),
              SuperDiff::Csi::EightBitColor.new(
                red: 3,
                green: 8,
                blue: 4,
                layer: :foreground
              ),
              SuperDiff::Csi::TwentyFourBitColor.new(
                red: 47,
                green: 164,
                blue: 59,
                layer: :foreground
              )
            ]
            string_to_inspect = [
              colored("This is a line", colors[0]),
              colored("And that's a line", colors[1]),
              colored("And there's a line too", colors[2])
            ].join("\n")

            tiered_lines =
              described_class.inspect_object(
                string_to_inspect,
                as_lines: true,
                type: :delete,
                indentation_level: 1
              )
            # TODO: Figure out how to represent a colorized string inside of an
            # already colorized string
            expect(tiered_lines).to match(
              [
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value:
                    %("\\e[34mThis is a line\\e[0m\\n\\e[38;5;176mAnd that's a line\\e[0m\\n\\e[38;2;47;59;164mAnd there's a line too\\e[0m")
                )
              ]
            )
          end
        end
      end
    end

    context "given an array" do
      context "containing only primitive values" do
        context "given as_lines: false" do
          it "returns an inspected version of the array" do
            string =
              described_class.inspect_object(["foo", 2, :baz], as_lines: false)
            expect(string).to eq(%(["foo", 2, :baz]))
          end
        end

        context "given as_lines: true" do
          it "returns an inspected version of the array as multiple Lines" do
            tiered_lines =
              described_class.inspect_object(
                ["foo", 2, :baz],
                as_lines: true,
                type: :delete,
                indentation_level: 1
              )
            expect(tiered_lines).to match(
              [
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "[",
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: %("foo"),
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "2",
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: ":baz",
                  add_comma: false
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "]",
                  collection_bookend: :close
                )
              ]
            )
          end
        end
      end

      context "containing other arrays" do
        context "given as_lines: false" do
          it "returns an inspected version of the array" do
            string =
              described_class.inspect_object(
                ["foo", %w[bar baz], "qux"],
                as_lines: false
              )
            expect(string).to eq(%(["foo", ["bar", "baz"], "qux"]))
          end
        end

        context "given as_lines: true" do
          it "returns an inspected version of the array as multiple Lines" do
            tiered_lines =
              described_class.inspect_object(
                ["foo", %w[bar baz], "qux"],
                as_lines: true,
                type: :delete,
                indentation_level: 1
              )
            expect(tiered_lines).to match(
              [
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "[",
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: %("foo"),
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "[",
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  value: %("bar"),
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  value: %("baz"),
                  add_comma: false
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "]",
                  add_comma: true,
                  collection_bookend: :close
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: %("qux"),
                  add_comma: false
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "]",
                  collection_bookend: :close
                )
              ]
            )
          end
        end
      end

      context "which is empty" do
        context "given as_lines: false" do
          it "returns an inspected version of the array" do
            string = described_class.inspect_object([], as_lines: false)
            expect(string).to eq("[]")
          end
        end

        context "given as_lines: true" do
          it "returns an inspected version of the array as multiple Lines" do
            tiered_lines =
              described_class.inspect_object(
                [],
                as_lines: true,
                type: :delete,
                indentation_level: 1
              )
            expect(tiered_lines).to match(
              [
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "[]"
                )
              ]
            )
          end
        end
      end
    end

    context "given a hash" do
      context "containing only primitive values" do
        context "where all of the keys are symbols" do
          context "given as_lines: false" do
            it "returns an inspected version of the hash" do
              string =
                described_class.inspect_object(
                  # rubocop:disable Style/HashSyntax
                  { foo: "bar", baz: "qux" },
                  # rubocop:enable Style/HashSyntax
                  as_lines: false
                )
              expect(string).to eq(%({ foo: "bar", baz: "qux" }))
            end
          end

          context "given as_lines: true" do
            it "returns an inspected version of the hash as multiple Lines" do
              tiered_lines =
                described_class.inspect_object(
                  # rubocop:disable Style/HashSyntax
                  { foo: "bar", baz: "qux" },
                  # rubocop:enable Style/HashSyntax
                  as_lines: true,
                  type: :delete,
                  indentation_level: 1
                )
              expect(tiered_lines).to match(
                [
                  an_object_having_attributes(
                    type: :delete,
                    indentation_level: 1,
                    value: "{",
                    collection_bookend: :open
                  ),
                  an_object_having_attributes(
                    type: :delete,
                    indentation_level: 2,
                    prefix: "foo: ",
                    value: %("bar"),
                    add_comma: true
                  ),
                  an_object_having_attributes(
                    type: :delete,
                    indentation_level: 2,
                    prefix: "baz: ",
                    value: %("qux"),
                    add_comma: false
                  ),
                  an_object_having_attributes(
                    type: :delete,
                    indentation_level: 1,
                    value: "}",
                    collection_bookend: :close
                  )
                ]
              )
            end
          end
        end

        context "where only some of the keys are symbols" do
          context "given as_lines: false" do
            it "returns an inspected version of the hash" do
              string =
                described_class.inspect_object(
                  { :foo => "bar", 2 => "baz" },
                  as_lines: false
                )
              expect(string).to eq(%({ :foo => "bar", 2 => "baz" }))
            end
          end

          context "given as_lines: true" do
            it "returns an inspected version of the hash as multiple Lines" do
              tiered_lines =
                described_class.inspect_object(
                  { :foo => "bar", 2 => "baz" },
                  as_lines: true,
                  type: :delete,
                  indentation_level: 1
                )
              expect(tiered_lines).to match(
                [
                  an_object_having_attributes(
                    type: :delete,
                    indentation_level: 1,
                    value: "{",
                    collection_bookend: :open
                  ),
                  an_object_having_attributes(
                    type: :delete,
                    indentation_level: 2,
                    prefix: ":foo => ",
                    value: %("bar"),
                    add_comma: true
                  ),
                  an_object_having_attributes(
                    type: :delete,
                    indentation_level: 2,
                    prefix: "2 => ",
                    value: %("baz"),
                    add_comma: false
                  ),
                  an_object_having_attributes(
                    type: :delete,
                    indentation_level: 1,
                    value: "}",
                    collection_bookend: :close
                  )
                ]
              )
            end
          end
        end
      end

      context "containing other hashes" do
        context "given as_lines: false" do
          it "returns an inspected version of the hash" do
            value_to_inspect = {
              # rubocop:disable Style/HashSyntax
              category_name: "Appliances",
              products_by_sku: {
                "EMDL-2934" => {
                  id: 4,
                  name: "Jordan Air"
                },
                "KDS-3912" => {
                  id: 8,
                  name: "Chevy Impala"
                }
              },
              number_of_products: 2
              # rubocop:enable Style/HashSyntax
            }
            string =
              described_class.inspect_object(value_to_inspect, as_lines: false)
            # rubocop:disable Metrics/LineLength
            expect(string).to eq(
              %({ category_name: "Appliances", products_by_sku: { "EMDL-2934" => { id: 4, name: "Jordan Air" }, "KDS-3912" => { id: 8, name: "Chevy Impala" } }, number_of_products: 2 })
            )
            # rubocop:enable Metrics/LineLength
          end
        end

        context "given as_lines: true" do
          it "returns an inspected version of the array as multiple Lines" do
            value_to_inspect = {
              # rubocop:disable Style/HashSyntax
              category_name: "Appliances",
              products_by_sku: {
                "EMDL-2934" => {
                  id: 4,
                  name: "George Foreman Grill"
                },
                "KDS-3912" => {
                  id: 8,
                  name: "Magic Bullet"
                }
              },
              number_of_products: 2
              # rubocop:enable Style/HashSyntax
            }
            tiered_lines =
              described_class.inspect_object(
                value_to_inspect,
                as_lines: true,
                type: :delete,
                indentation_level: 1
              )
            expect(tiered_lines).to match(
              [
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "{",
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  prefix: "category_name: ",
                  value: %("Appliances"),
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  prefix: "products_by_sku: ",
                  value: "{",
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  prefix: %("EMDL-2934" => ),
                  value: "{",
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 4,
                  prefix: "id: ",
                  value: "4",
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 4,
                  prefix: "name: ",
                  value: %("George Foreman Grill"),
                  add_comma: false
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  prefix: "",
                  value: "}",
                  add_comma: true,
                  collection_bookend: :close
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  prefix: %("KDS-3912" => ),
                  value: "{",
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 4,
                  prefix: "id: ",
                  value: "8",
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 4,
                  prefix: "name: ",
                  value: %("Magic Bullet"),
                  add_comma: false
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  prefix: "",
                  value: "}",
                  collection_bookend: :close
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  prefix: "",
                  value: "}",
                  add_comma: true,
                  collection_bookend: :close
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  prefix: "number_of_products: ",
                  value: "2"
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  prefix: "",
                  value: "}"
                )
              ]
            )
          end
        end
      end

      context "which is empty" do
        context "given as_lines: false" do
          it "returns an inspected version of the array" do
            string = described_class.inspect_object({}, as_lines: false)
            expect(string).to eq("{}")
          end
        end

        context "given as_lines: true" do
          it "returns an inspected version of the array" do
            tiered_lines =
              described_class.inspect_object(
                {},
                as_lines: true,
                type: :delete,
                indentation_level: 1
              )
            expect(tiered_lines).to match(
              [
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "{}"
                )
              ]
            )
          end
        end
      end
    end

    context "given a Time object" do
      context "that does not have an associated time zone" do
        context "given as_lines: false" do
          it "returns a representation of the time on a single line" do
            inspection =
              described_class.inspect_object(
                Time.new(2021, 5, 5, 10, 23, 28.1234567891, "-05:00"),
                as_lines: false
              )
            expect(inspection).to eq(
              "#<Time 2021-05-05 10:23:28+(34749996836695/281474976710656) -05:00>"
            )
          end
        end

        context "given as_lines: true" do
          it "returns a representation of the time across multiple lines" do
            inspection =
              described_class.inspect_object(
                Time.new(2021, 5, 5, 10, 23, 28.1234567891, "-05:00"),
                as_lines: true,
                type: :delete,
                indentation_level: 1
              )
            expect(inspection).to match(
              [
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "#<Time {",
                  add_comma: false,
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "year: 2021",
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "month: 5",
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "day: 5",
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "hour: 10",
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "min: 23",
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "sec: 28",
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "subsec: (34749996836695/281474976710656)",
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "zone: nil",
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "utc_offset: -18000",
                  add_comma: false,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "}>",
                  add_comma: false,
                  collection_bookend: :close
                )
              ]
            )
          end
        end
      end

      context "that has an associated time zone" do
        around do |example|
          ClimateControl.modify(TZ: "America/Chicago", &example)
        end

        context "given as_lines: false" do
          it "returns a representation of the time on a single line" do
            inspection =
              described_class.inspect_object(
                Time.new(2021, 5, 5, 10, 23, 28.1234567891),
                as_lines: false
              )
            expect(inspection).to eq(
              "#<Time 2021-05-05 10:23:28+(34749996836695/281474976710656) -05:00 (CDT)>"
            )
          end
        end

        context "given as_lines: true" do
          it "returns a representation of the time across multiple lines" do
            inspection =
              described_class.inspect_object(
                Time.new(2021, 5, 5, 10, 23, 28.1234567891),
                as_lines: true,
                type: :delete,
                indentation_level: 1
              )
            expect(inspection).to match(
              [
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "#<Time {",
                  add_comma: false,
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "year: 2021",
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "month: 5",
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "day: 5",
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "hour: 10",
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "min: 23",
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "sec: 28",
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "subsec: (34749996836695/281474976710656)",
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: %(zone: "CDT"),
                  add_comma: true,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "utc_offset: -18000",
                  add_comma: false,
                  collection_bookend: nil
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "}>",
                  add_comma: false,
                  collection_bookend: :close
                )
              ]
            )
          end
        end
      end
    end

    context "given a class" do
      context "given as_lines: false" do
        it "returns an inspected version of the object" do
          string =
            described_class.inspect_object(
              SuperDiff::Test::Person,
              as_lines: false
            )
          expect(string).to eq("SuperDiff::Test::Person")
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the object" do
          tiered_lines =
            described_class.inspect_object(
              SuperDiff::Test::Person,
              as_lines: true,
              type: :delete,
              indentation_level: 1
            )
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: "SuperDiff::Test::Person"
              )
            ]
          )
        end
      end
    end

    # TODO: Add when empty
    context "given a custom object" do
      context "containing only primitive values" do
        context "given as_lines: false" do
          it "returns an inspected version of the object" do
            string =
              described_class.inspect_object(
                SuperDiff::Test::Person.new(name: "Doc", age: 58),
                as_lines: false
              )
            expect(string).to eq(
              %(#<SuperDiff::Test::Person name: "Doc", age: 58>)
            )
          end
        end

        context "given as_lines: true" do
          it "returns an inspected version of the object as multiple Lines" do
            tiered_lines =
              described_class.inspect_object(
                SuperDiff::Test::Person.new(name: "Doc", age: 58),
                as_lines: true,
                type: :delete,
                indentation_level: 1
              )
            expect(tiered_lines).to match(
              [
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "#<SuperDiff::Test::Person {"
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  prefix: "name: ",
                  value: %("Doc"),
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  prefix: "age: ",
                  value: "58",
                  add_comma: false
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "}>"
                )
              ]
            )
          end
        end
      end

      context "containing other custom objects" do
        context "given as_lines: false" do
          it "returns an inspected version of the object" do
            string =
              described_class.inspect_object(
                SuperDiff::Test::Customer.new(
                  name: "Marty McFly",
                  shipping_address:
                    SuperDiff::Test::ShippingAddress.new(
                      line_1: "123 Main St.",
                      line_2: "",
                      city: "Hill Valley",
                      state: "CA",
                      zip: "90382"
                    ),
                  phone: "111-222-3333"
                ),
                as_lines: false
              )
            expect(string).to eq(
              # rubocop:disable Metrics/LineLength
              %(#<SuperDiff::Test::Customer name: "Marty McFly", shipping_address: #<SuperDiff::Test::ShippingAddress line_1: "123 Main St.", line_2: "", city: "Hill Valley", state: "CA", zip: "90382">, phone: "111-222-3333">)
              # rubocop:enable Metrics/LineLength
            )
          end
        end

        context "given as_lines: true" do
          it "returns an inspected version of the object as multiple Lines" do
            tiered_lines =
              described_class.inspect_object(
                SuperDiff::Test::Customer.new(
                  name: "Marty McFly",
                  shipping_address:
                    SuperDiff::Test::ShippingAddress.new(
                      line_1: "123 Main St.",
                      line_2: "",
                      city: "Hill Valley",
                      state: "CA",
                      zip: "90382"
                    ),
                  phone: "111-222-3333"
                ),
                as_lines: true,
                type: :delete,
                indentation_level: 1
              )
            expect(tiered_lines).to match(
              [
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "#<SuperDiff::Test::Customer {",
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  prefix: "name: ",
                  value: %("Marty McFly"),
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  prefix: "shipping_address: ",
                  value: "#<SuperDiff::Test::ShippingAddress {",
                  add_comma: false,
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  prefix: "line_1: ",
                  value: %("123 Main St.")
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  prefix: "line_2: ",
                  value: %(""),
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  prefix: "city: ",
                  value: %("Hill Valley"),
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  prefix: "state: ",
                  value: %("CA"),
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  prefix: "zip: ",
                  value: %("90382"),
                  add_comma: false
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "}>",
                  add_comma: true,
                  collection_bookend: :close
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  prefix: "phone: ",
                  value: %("111-222-3333"),
                  add_comma: false
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "}>",
                  add_comma: false,
                  collection_bookend: :close
                )
              ]
            )
          end
        end
      end
    end

    context "given a non-custom object" do
      context "containing only primitive values" do
        context "given as_lines: false" do
          it "returns an inspected version of the object" do
            string =
              described_class.inspect_object(
                SuperDiff::Test::Item.new(name: "mac and cheese", quantity: 2),
                as_lines: false
              )
            expect(string).to match(
              /\A#<SuperDiff::Test::Item:0x[a-z0-9]+ @name="mac and cheese", @quantity=2>\Z/
            )
          end
        end

        context "given as_lines: true" do
          it "returns an inspected version of the object as multiple Lines" do
            tiered_lines =
              described_class.inspect_object(
                SuperDiff::Test::Item.new(name: "mac and cheese", quantity: 2),
                as_lines: true,
                type: :delete,
                indentation_level: 1
              )
            expect(tiered_lines).to match(
              [
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value:
                    a_string_matching(/#<SuperDiff::Test::Item:0x[a-f0-9]+ \{/),
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  prefix: "@name=",
                  value: %("mac and cheese"),
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  prefix: "@quantity=",
                  value: "2",
                  add_comma: false
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "}>",
                  collection_bookend: :close
                )
              ]
            )
          end
        end
      end

      context "containing other custom objects" do
        context "given as_lines: false" do
          it "returns an inspected version of the object" do
            string =
              described_class.inspect_object(
                SuperDiff::Test::Order.new(
                  [
                    SuperDiff::Test::Item.new(name: "ham", quantity: 1),
                    SuperDiff::Test::Item.new(name: "eggs", quantity: 2),
                    SuperDiff::Test::Item.new(name: "cheese", quantity: 1)
                  ]
                ),
                as_lines: false
              )
            expect(string).to match(
              # rubocop:disable Metrics/LineLength
              /\A#<SuperDiff::Test::Order:0x[a-z0-9]+ @items=\[#<SuperDiff::Test::Item:0x[a-z0-9]+ @name="ham", @quantity=1>, #<SuperDiff::Test::Item:0x[a-z0-9]+ @name="eggs", @quantity=2>, #<SuperDiff::Test::Item:0x[a-z0-9]+ @name="cheese", @quantity=1>\]>\Z/
              # rubocop:enable Metrics/LineLength
            )
          end
        end

        context "given as_lines: true" do
          it "returns an inspected version of the object as multiple Lines" do
            tiered_lines =
              described_class.inspect_object(
                SuperDiff::Test::Order.new(
                  [
                    SuperDiff::Test::Item.new(name: "ham", quantity: 1),
                    SuperDiff::Test::Item.new(name: "eggs", quantity: 2),
                    SuperDiff::Test::Item.new(name: "cheese", quantity: 1)
                  ]
                ),
                as_lines: true,
                type: :delete,
                indentation_level: 1
              )
            expect(tiered_lines).to match(
              [
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value:
                    a_string_matching(
                      /#<SuperDiff::Test::Order:0x[a-f0-9]+ \{/
                    ),
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  prefix: "@items=",
                  value: "[",
                  add_comma: false,
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  value:
                    a_string_matching(/#<SuperDiff::Test::Item:0x[a-f0-9]+ \{/),
                  add_comma: false,
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 4,
                  prefix: "@name=",
                  value: %("ham"),
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 4,
                  prefix: "@quantity=",
                  value: "1",
                  add_comma: false
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  value: "}>",
                  add_comma: true,
                  collection_bookend: :close
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  value:
                    a_string_matching(/#<SuperDiff::Test::Item:0x[a-f0-9]+ \{/),
                  add_comma: false,
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 4,
                  prefix: "@name=",
                  value: %("eggs"),
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 4,
                  prefix: "@quantity=",
                  value: "2",
                  add_comma: false
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  value: "}>",
                  add_comma: true,
                  collection_bookend: :close
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  value:
                    a_string_matching(/#<SuperDiff::Test::Item:0x[a-f0-9]+ \{/),
                  add_comma: false,
                  collection_bookend: :open
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 4,
                  prefix: "@name=",
                  value: %("cheese"),
                  add_comma: true
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 4,
                  prefix: "@quantity=",
                  value: "1",
                  add_comma: false
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 3,
                  value: "}>",
                  add_comma: false,
                  collection_bookend: :close
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 2,
                  value: "]",
                  add_comma: false,
                  collection_bookend: :close
                ),
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value: "}>",
                  add_comma: false,
                  collection_bookend: :close
                )
              ]
            )
          end
        end
      end

      context "which is empty" do
        context "given as_lines: false" do
          it "returns an inspected version of the array" do
            string =
              described_class.inspect_object(
                SuperDiff::Test::EmptyClass.new,
                as_lines: false
              )
            expect(string).to match(
              /#<SuperDiff::Test::EmptyClass:0x[a-z0-9]+>/
            )
          end
        end

        context "given as_lines: true" do
          it "returns an inspected version of the array" do
            inspection =
              described_class.inspect_object(
                SuperDiff::Test::EmptyClass.new,
                as_lines: true,
                type: :delete,
                indentation_level: 1
              )
            expect(inspection).to match(
              [
                an_object_having_attributes(
                  type: :delete,
                  indentation_level: 1,
                  value:
                    a_string_matching(
                      /#<SuperDiff::Test::EmptyClass:0x[a-z0-9]+>/
                    )
                )
              ]
            )
          end
        end
      end
    end

    context "given a combination of all kinds of values" do
      context "given as_lines: false" do
        it "returns an inspected version of the object" do
          string =
            described_class.inspect_object(
              {
                state: :down,
                errors: [
                  "Container A-234 is partially damaged",
                  "Vessel B042 was attacked by raccoons",
                  "Product FDK-3429 is out of stock"
                ],
                mission_critical: true,
                serviceable: false,
                outstanding_orders: [
                  SuperDiff::Test::Order.new(
                    [
                      SuperDiff::Test::Item.new(name: "ham", quantity: 1),
                      SuperDiff::Test::Item.new(name: "eggs", quantity: 2),
                      SuperDiff::Test::Item.new(name: "cheese", quantity: 1)
                    ]
                  )
                ],
                customers: [
                  SuperDiff::Test::Customer.new(
                    name: "Marty McFly",
                    shipping_address:
                      SuperDiff::Test::ShippingAddress.new(
                        line_1: "123 Baltic Ave.",
                        line_2: "",
                        city: "Hill Valley",
                        state: "CA",
                        zip: "90382"
                      ),
                    phone: "111-111-1111"
                  ),
                  SuperDiff::Test::Customer.new(
                    name: "Doc Brown",
                    shipping_address:
                      SuperDiff::Test::ShippingAddress.new(
                        line_1: "456 Park Place",
                        line_2: "",
                        city: "Beverly Hills",
                        state: "CA",
                        zip: "90210"
                      ),
                    phone: "222-222-2222"
                  )
                ]
              },
              as_lines: false
            )
          expect(string).to match(
            # rubocop:disable Metrics/LineLength
            /\A\{ state: :down, errors: \["Container A-234 is partially damaged", "Vessel B042 was attacked by raccoons", "Product FDK-3429 is out of stock"\], mission_critical: true, serviceable: false, outstanding_orders: \[#<SuperDiff::Test::Order:0x[a-z0-9]+ @items=\[#<SuperDiff::Test::Item:0x[a-z0-9]+ @name="ham", @quantity=1>, #<SuperDiff::Test::Item:0x[a-z0-9]+ @name="eggs", @quantity=2>, #<SuperDiff::Test::Item:0x[a-z0-9]+ @name="cheese", @quantity=1>\]>\], customers: \[#<SuperDiff::Test::Customer name: "Marty McFly", shipping_address: #<SuperDiff::Test::ShippingAddress line_1: "123 Baltic Ave.", line_2: "", city: "Hill Valley", state: "CA", zip: "90382">, phone: "111-111-1111">, #<SuperDiff::Test::Customer name: "Doc Brown", shipping_address: #<SuperDiff::Test::ShippingAddress line_1: "456 Park Place", line_2: "", city: "Beverly Hills", state: "CA", zip: "90210">, phone: "222-222-2222">\] \}\Z/
            # rubocop:enable Metrics/LineLength
          )
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the object as multiple Lines" do
          tiered_lines =
            described_class.inspect_object(
              {
                state: :down,
                errors: [
                  "Container A-234 is partially damaged",
                  "Vessel B042 was attacked by raccoons",
                  "Product FDK-3429 is out of stock"
                ],
                mission_critical: true,
                serviceable: false,
                outstanding_orders: [
                  SuperDiff::Test::Order.new(
                    [
                      SuperDiff::Test::Item.new(name: "ham", quantity: 1),
                      SuperDiff::Test::Item.new(name: "eggs", quantity: 2),
                      SuperDiff::Test::Item.new(name: "cheese", quantity: 1)
                    ]
                  )
                ],
                customers: [
                  SuperDiff::Test::Customer.new(
                    name: "Marty McFly",
                    shipping_address:
                      SuperDiff::Test::ShippingAddress.new(
                        line_1: "123 Baltic Ave.",
                        line_2: "",
                        city: "Hill Valley",
                        state: "CA",
                        zip: "90382"
                      ),
                    phone: "111-111-1111"
                  ),
                  SuperDiff::Test::Customer.new(
                    name: "Doc Brown",
                    shipping_address:
                      SuperDiff::Test::ShippingAddress.new(
                        line_1: "456 Park Place",
                        line_2: "",
                        city: "Beverly Hills",
                        state: "CA",
                        zip: "90210"
                      ),
                    phone: "222-222-2222"
                  )
                ]
              },
              as_lines: true,
              type: :delete,
              indentation_level: 1
            )
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: "{",
                collection_bookend: :open
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                prefix: "state: ",
                value: ":down",
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                prefix: "errors: ",
                value: "[",
                collection_bookend: :open
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 3,
                value: %("Container A-234 is partially damaged"),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 3,
                value: %("Vessel B042 was attacked by raccoons"),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 3,
                value: %("Product FDK-3429 is out of stock"),
                add_comma: false
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                value: "]",
                collection_bookend: :close
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                prefix: "mission_critical: ",
                value: "true",
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                prefix: "serviceable: ",
                value: "false",
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                prefix: "outstanding_orders: ",
                value: "[",
                collection_bookend: :open
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 3,
                value:
                  a_string_matching(/#<SuperDiff::Test::Order:0x[a-f0-9]+ \{/),
                collection_bookend: :open
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 4,
                prefix: "@items=",
                value: "[",
                collection_bookend: :open
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                value:
                  a_string_matching(/#<SuperDiff::Test::Item:0x[a-f0-9]+ \{/),
                collection_bookend: :open
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 6,
                prefix: "@name=",
                value: %("ham"),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 6,
                prefix: "@quantity=",
                value: "1",
                add_comma: false
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                value: "}>",
                collection_bookend: :close
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                value:
                  a_string_matching(/#<SuperDiff::Test::Item:0x[a-f0-9]+ \{/),
                collection_bookend: :open
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 6,
                prefix: "@name=",
                value: %("eggs"),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 6,
                prefix: "@quantity=",
                value: "2",
                add_comma: false
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                value: "}>",
                collection_bookend: :close
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                value:
                  a_string_matching(/#<SuperDiff::Test::Item:0x[a-f0-9]+ \{/),
                collection_bookend: :open
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 6,
                prefix: "@name=",
                value: %("cheese"),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 6,
                prefix: "@quantity=",
                value: "1",
                add_comma: false
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                value: "}>",
                collection_bookend: :close
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 4,
                value: "]",
                collection_bookend: :close
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 3,
                value: "}>",
                collection_bookend: :close
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                value: "]",
                collection_bookend: :close
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                prefix: "customers: ",
                value: "[",
                collection_bookend: :open
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 3,
                value: "#<SuperDiff::Test::Customer {",
                collection_bookend: :open
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 4,
                prefix: "name: ",
                value: %("Marty McFly"),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 4,
                prefix: "shipping_address: ",
                value: "#<SuperDiff::Test::ShippingAddress {",
                collection_bookend: :open
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                prefix: "line_1: ",
                value: %("123 Baltic Ave."),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                prefix: "line_2: ",
                value: %(""),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                prefix: "city: ",
                value: %("Hill Valley"),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                prefix: "state: ",
                value: %("CA"),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                prefix: "zip: ",
                value: %("90382"),
                add_comma: false
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 4,
                value: "}>",
                add_comma: true,
                collection_bookend: :close
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 4,
                prefix: "phone: ",
                value: %("111-111-1111"),
                add_comma: false
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 3,
                value: "}>",
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 3,
                value: "#<SuperDiff::Test::Customer {",
                collection_bookend: :open
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 4,
                prefix: "name: ",
                value: %("Doc Brown"),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 4,
                prefix: "shipping_address: ",
                value: "#<SuperDiff::Test::ShippingAddress {",
                collection_bookend: :open
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                prefix: "line_1: ",
                value: %("456 Park Place"),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                prefix: "line_2: ",
                value: %(""),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                prefix: "city: ",
                value: %("Beverly Hills"),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                prefix: "state: ",
                value: %("CA"),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 5,
                prefix: "zip: ",
                value: %("90210"),
                add_comma: false
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 4,
                value: "}>",
                add_comma: true,
                collection_bookend: :close
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 4,
                prefix: "phone: ",
                value: %("222-222-2222"),
                add_comma: false
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 3,
                value: "}>",
                add_comma: false,
                collection_bookend: :close
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                value: "]",
                add_comma: false,
                collection_bookend: :close
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: "}",
                collection_bookend: :close
              )
            ]
          )
        end
      end
    end

    context "given a data structure that refers to itself somewhere inside of it" do
      context "given as_lines: false" do
        it "replaces the reference with ∙∙∙" do
          value = %w[a b c]
          value.insert(1, value)
          string = described_class.inspect_object(value, as_lines: false)
          expect(string).to eq(%(["a", ∙∙∙, "b", "c"]))
        end
      end

      context "given as_lines: true" do
        it "replaces the reference with ∙∙∙" do
          value = %w[a b c]
          value.insert(1, value)
          tiered_lines =
            described_class.inspect_object(
              value,
              as_lines: true,
              type: :delete,
              indentation_level: 1
            )
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: "[",
                collection_bookend: :open
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                value: %("a"),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                value: "∙∙∙",
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                value: %("b"),
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                value: %("c"),
                add_comma: false
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: "]",
                collection_bookend: :close
              )
            ]
          )
        end
      end
    end

    context "given a data structure that refers to itself in a nested data structure"
  end
end
