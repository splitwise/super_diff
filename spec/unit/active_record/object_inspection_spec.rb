require "spec_helper"

RSpec.describe SuperDiff, type: :unit do
  describe ".inspect_object", "for ActiveRecord objects", active_record: true do
    context "given an ActiveRecord object" do
      context "given as_lines: false" do
        it "returns an inspected version of the object" do
          string = described_class.inspect_object(
            SuperDiff::Test::Models::ActiveRecord::Person.new(
              name: "Elliot",
              age: 31,
            ),
            as_lines: false,
          )
          expect(string).to eq(
            %(#<SuperDiff::Test::Models::ActiveRecord::Person id: nil, age: 31, name: "Elliot">)
          )
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the object as multiple Lines" do
          tiered_lines = described_class.inspect_object(
            SuperDiff::Test::Models::ActiveRecord::Person.new(
              name: "Elliot",
              age: 31,
            ),
            as_lines: true,
            type: :delete,
            indentation_level: 1,
          )
          expect(tiered_lines).to match([
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %(#<SuperDiff::Test::Models::ActiveRecord::Person {),
              collection_bookend: :open,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              prefix: %(id: ),
              value: %(nil),
              add_comma: true,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              prefix: %(age: ),
              value: %(31),
              add_comma: true,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              prefix: %(name: ),
              value: %("Elliot"),
              add_comma: false,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %(}>),
              collection_bookend: :close,
            ),
          ])
        end
      end
    end

    context "given an ActiveRecord::Relation object" do
      context "given as_lines: false" do
        it "returns an inspected version of the Relation" do
          SuperDiff::Test::Models::ActiveRecord::Person.create!(
            name: "Marty",
            age: 19,
          )
          SuperDiff::Test::Models::ActiveRecord::Person.create!(
            name: "Jennifer",
            age: 17,
          )

          string = described_class.inspect_object(
            SuperDiff::Test::Models::ActiveRecord::Person.all,
            as_lines: false,
          )

          expect(string).to eq(
            %(#<ActiveRecord::Relation [#<SuperDiff::Test::Models::ActiveRecord::Person id: 1, age: 19, name: "Marty">, #<SuperDiff::Test::Models::ActiveRecord::Person id: 2, age: 17, name: "Jennifer">]>)
          )
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the Relation as multiple Lines" do
          SuperDiff::Test::Models::ActiveRecord::Person.create!(
            name: "Marty",
            age: 19,
          )
          SuperDiff::Test::Models::ActiveRecord::Person.create!(
            name: "Jennifer",
            age: 17,
          )

          tiered_lines = described_class.inspect_object(
            SuperDiff::Test::Models::ActiveRecord::Person.all,
            as_lines: true,
            type: :delete,
            indentation_level: 1,
          )

          expect(tiered_lines).to match([
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %(#<ActiveRecord::Relation [),
              collection_bookend: :open,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              value: %(#<SuperDiff::Test::Models::ActiveRecord::Person {),
              collection_bookend: :open,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 3,
              prefix: %(id: ),
              value: %(1),
              add_comma: true,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 3,
              prefix: %(age: ),
              value: %(19),
              add_comma: true,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 3,
              prefix: %(name: ),
              value: %("Marty"),
              add_comma: false,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              value: %(}>),
              collection_bookend: :close,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              value: %(#<SuperDiff::Test::Models::ActiveRecord::Person {),
              collection_bookend: :open,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 3,
              prefix: %(id: ),
              value: %(2),
              add_comma: true,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 3,
              prefix: %(age: ),
              value: %(17),
              add_comma: true,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 3,
              prefix: %(name: ),
              value: %("Jennifer"),
              add_comma: false,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              value: %(}>),
              collection_bookend: :close,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %(]>),
              collection_bookend: :close,
            ),
          ])
        end
      end
    end

    context "given a HashWithIndifferentAccess" do
      context "given as_lines: false" do
        it "returns an inspected version of the object" do
          string = described_class.inspect_object(
            HashWithIndifferentAccess.new({
              line_1: "123 Main St.",
              city: "Hill Valley",
              state: "CA",
              zip: "90382",
            }),
            as_lines: false,
          )
          expect(string).to eq(
            %(#<HashWithIndifferentAccess { "line_1" => "123 Main St.", "city" => "Hill Valley", "state" => "CA", "zip" => "90382" }>),
          )
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the object as multiple Lines" do
          tiered_lines = described_class.inspect_object(
            HashWithIndifferentAccess.new({
              line_1: "123 Main St.",
              city: "Hill Valley",
              state: "CA",
              zip: "90382",
            }),
            as_lines: true,
            type: :delete,
            indentation_level: 1,
          )
          expect(tiered_lines).to match([
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %(#<HashWithIndifferentAccess {),
              collection_bookend: :open,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              prefix: %("line_1" => ),
              value: %("123 Main St."),
              add_comma: true,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              prefix: %("city" => ),
              value: %("Hill Valley"),
              add_comma: true,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              prefix: %("state" => ),
              value: %("CA"),
              add_comma: true,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 2,
              prefix: %("zip" => ),
              value: %("90382"),
              add_comma: false,
            ),
            an_object_having_attributes(
              type: :delete,
              indentation_level: 1,
              value: %(}>),
              collection_bookend: :close,
            ),
          ])
        end
      end
    end
  end
end
