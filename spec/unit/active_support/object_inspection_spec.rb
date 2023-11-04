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
  end
end
