require "spec_helper"

RSpec.describe SuperDiff, type: :unit do
  describe ".inspect_object",
           "for ActiveSupport objects",
           active_support: true do
    context "given an ActiveSupport::OrderedOptions object" do
      context "given as_lines: false" do
        it "returns an inspected version of the object" do
          string =
            described_class.inspect_object(
              ::ActiveSupport::OrderedOptions[name: "Bob", age: 42],
              as_lines: false
            )
          expect(string).to eq(%(#<OrderedOptions { name: "Bob", age: 42 }>))
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the object as multiple Lines" do
          tiered_lines =
            described_class.inspect_object(
              ::ActiveSupport::OrderedOptions[name: "Bob", age: 42],
              as_lines: true,
              type: :delete,
              indentation_level: 1
            )
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: "#<OrderedOptions {",
                collection_bookend: :open
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                prefix: "name: ",
                value: "\"Bob\"",
                add_comma: true
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                prefix: "age: ",
                value: "42",
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

    context "given a DateTime object" do
      context "given as_lines: false" do
        it "returns a representation of the datetime on a single line" do
          inspection =
            described_class.inspect_object(
              DateTime.new(2021, 5, 5, 10, 23, 28.123456789123, "-05:00"),
              as_lines: false
            )
          expect(inspection).to eq(
            "#<DateTime 2021-05-05 10:23:28+(123456789/1000000000) -05:00 (-05:00)>"
          )
        end
      end

      context "given as_lines: true" do
        it "returns a representation of the datetime across multiple lines" do
          inspection =
            described_class.inspect_object(
              DateTime.new(2021, 5, 5, 10, 23, 28.1234567891, "-05:00"),
              as_lines: true,
              type: :delete,
              indentation_level: 1
            )
          expect(inspection).to match(
            [
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: "#<DateTime {",
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
                value: "subsec: (123456789/1000000000)",
                add_comma: true,
                collection_bookend: nil
              ),
              an_object_having_attributes(
                type: :delete,
                indentation_level: 2,
                value: "zone: \"-05:00\"",
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
end
