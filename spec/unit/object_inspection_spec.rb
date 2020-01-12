require "spec_helper"

RSpec.describe SuperDiff::ObjectInspection do
  describe ".inspect" do
    context "given nil" do
      context "given as_single_line: true" do
        it "returns nil, inspected" do
          inspection = described_class.inspect(nil, as_single_line: true)
          expect(inspection).to eq("nil")
        end
      end

      context "given as_single_line: false" do
        it "returns nil, inspected" do
          inspection = described_class.inspect(nil, as_single_line: false)
          expect(inspection).to eq("nil")
        end
      end
    end

    context "given true" do
      context "given as_single_line: true" do
        it "returns nil, inspected" do
          inspection = described_class.inspect(nil, as_single_line: true)
          expect(inspection).to eq("nil")
        end
      end

      context "given as_single_line: false" do
        it "returns nil, inspected" do
          inspection = described_class.inspect(nil, as_single_line: false)
          expect(inspection).to eq("nil")
        end
      end
    end

    context "given false" do
      context "given as_single_line: false" do
        it "returns false, inspected" do
          inspection = described_class.inspect(false, as_single_line: false)
          expect(inspection).to eq("false")
        end
      end

      context "given as_single_line: false" do
        it "returns false, inspected" do
          inspection = described_class.inspect(false, as_single_line: false)
          expect(inspection).to eq("false")
        end
      end
    end

    context "given a number" do
      context "given as_single_line: true" do
        it "returns the number as a string" do
          inspection = described_class.inspect(3, as_single_line: true)
          expect(inspection).to eq("3")
        end
      end

      context "given as_single_line: false" do
        it "returns the number as a string" do
          inspection = described_class.inspect(3, as_single_line: false)
          expect(inspection).to eq("3")
        end
      end
    end

    context "given a symbol" do
      context "given as_single_line: true" do
        it "returns the symbol, inspected" do
          inspection = described_class.inspect(:foo, as_single_line: true)
          expect(inspection).to eq(":foo")
        end
      end

      context "given as_single_line: false" do
        it "returns the symbol, inspected" do
          inspection = described_class.inspect(:foo, as_single_line: false)
          expect(inspection).to eq(":foo")
        end
      end
    end

    context "given a regex" do
      context "given as_single_line: true" do
        it "returns the regex, inspected" do
          inspection = described_class.inspect(/foo/, as_single_line: true)
          expect(inspection).to eq("/foo/")
        end
      end

      context "given as_single_line: false" do
        it "returns the regex, inspected" do
          inspection = described_class.inspect(/foo/, as_single_line: false)
          expect(inspection).to eq("/foo/")
        end
      end
    end

    context "given a single-line string" do
      it "returns the string surrounded by quotes" do
        inspection = described_class.inspect("Marty", as_single_line: true)
        expect(inspection).to eq('"Marty"')
      end
    end

    context "given a multi-line string" do
      context "that does not contain color codes" do
        it "returns the string surrounded by quotes, with newline characters escaped" do
          inspection = described_class.inspect(
            "This is a line\nAnd that's a line\nAnd there's a line too",
            as_single_line: true,
          )
          expect(inspection).to eq(
            %("This is a line\\nAnd that's a line\\nAnd there's a line too"),
          )
        end
      end

      context "that contains color codes" do
        it "escapes the color codes" do
          colors = [
            SuperDiff::Csi::FourBitColor.new(:blue, layer: :foreground),
            SuperDiff::Csi::EightBitColor.new(
              red: 3,
              green: 8,
              blue: 4,
              layer: :foreground,
            ),
            SuperDiff::Csi::TwentyFourBitColor.new(
              red: 47,
              green: 164,
              blue: 59,
              layer: :foreground,
            ),
          ]
          string_to_inspect = [
            colorize("This is a line", colors[0]),
            colorize("And that's a line", colors[1]),
            colorize("And there's a line too", colors[2]),
          ].join("\n")

          inspection = described_class.inspect(
            string_to_inspect,
            as_single_line: true,
          )
          # TODO: Figure out how to represent a colorized string inside of an
          # already colorized string
          expect(inspection).to eq(<<~INSPECTION.rstrip)
            "\\e[34mThis is a line\\e[0m\\n\\e[38;5;176mAnd that's a line\\e[0m\\n\\e[38;2;47;59;164mAnd there's a line too\\e[0m"
          INSPECTION
        end
      end
    end

    context "given an array" do
      context "containing only primitive values" do
        context "given as_single_line: true" do
          it "returns a representation of the array on a single line" do
            inspection = described_class.inspect(
              ["foo", 2, :baz],
              as_single_line: true,
            )
            expect(inspection).to eq(%(["foo", 2, :baz]))
          end
        end

        context "given as_single_line: false" do
          it "returns a representation of the array across multiple lines" do
            inspection = described_class.inspect(
              ["foo", 2, :baz],
              as_single_line: false,
            )
            expect(inspection).to eq(<<~INSPECTION.rstrip)
              [
                "foo",
                2,
                :baz
              ]
            INSPECTION
          end
        end
      end

      context "containing other arrays" do
        context "given as_single_line: true" do
          it "returns a representation of the array on a single line" do
            inspection = described_class.inspect(
              [
                "foo",
                ["bar", "baz"],
                "qux",
              ],
              as_single_line: true,
            )
            expect(inspection).to eq(%(["foo", ["bar", "baz"], "qux"]))
          end
        end

        context "given as_single_line: false" do
          it "returns a representation of the array across multiple lines" do
            inspection = described_class.inspect(
              [
                "foo",
                ["bar", "baz"],
                "qux",
              ],
              as_single_line: false,
            )
            expect(inspection).to eq(<<~INSPECTION.rstrip)
              [
                "foo",
                [
                  "bar",
                  "baz"
                ],
                "qux"
              ]
            INSPECTION
          end
        end
      end

      context "which is empty" do
        context "given as_single_line: true" do
          it "returns a representation of the array on a single line" do
            inspection = described_class.inspect([], as_single_line: true)
            expect(inspection).to eq(%([]))
          end
        end

        context "given as_single_line: false" do
          it "returns a representation of the array on a single line" do
            inspection = described_class.inspect([], as_single_line: false)
            expect(inspection).to eq(%([]))
          end
        end
      end
    end

    context "given a hash" do
      context "containing only primitive values" do
        context "where all of the keys are symbols" do
          context "given as_single_line: true" do
            it "returns a representation of the hash on a single line" do
              inspection = described_class.inspect(
                # rubocop:disable Style/HashSyntax
                { :foo => "bar", :baz => "qux" },
                # rubocop:enable Style/HashSyntax
                as_single_line: true,
              )
              expect(inspection).to eq(%({ foo: "bar", baz: "qux" }))
            end
          end

          context "given as_single_line: false" do
            it "returns a representation of the hash across multiple lines" do
              inspection = described_class.inspect(
                # rubocop:disable Style/HashSyntax
                { :foo => "bar", :baz => "qux" },
                # rubocop:enable Style/HashSyntax
                as_single_line: false,
              )
              expect(inspection).to eq(<<~INSPECTION.rstrip)
                {
                  foo: "bar",
                  baz: "qux"
                }
              INSPECTION
            end
          end
        end

        context "where only some of the keys are symbols" do
          context "given as_single_line: true" do
            it "returns a representation of the hash on a single line" do
              inspection = described_class.inspect(
                { :foo => "bar", 2 => "baz" },
                as_single_line: true,
              )
              expect(inspection).to eq(%({ :foo => "bar", 2 => "baz" }))
            end
          end

          context "given as_single_line: false" do
            it "returns a representation of the hash across multiple lines" do
              inspection = described_class.inspect(
                { :foo => "bar", 2 => "baz" },
                as_single_line: false,
              )
              expect(inspection).to eq(<<~INSPECTION.rstrip)
                {
                  :foo => "bar",
                  2 => "baz"
                }
              INSPECTION
            end
          end
        end
      end

      context "containing other hashes" do
        context "given as_single_line: true" do
          it "returns a representation of the hash on a single line" do
            # TODO: Update this with a key/value pair before AND after
            value_to_inspect = {
              # rubocop:disable Style/HashSyntax
              :category_name => "Appliances",
              :products_by_sku => {
                "EMDL-2934" => { :id => 4, :name => "Jordan Air" },
                "KDS-3912" => { :id => 8, :name => "Chevy Impala" },
              },
              :number_of_products => 2,
              # rubocop:enable Style/HashSyntax
            }
            inspection = described_class.inspect(
              value_to_inspect,
              as_single_line: true,
            )
            # rubocop:disable Metrics/LineLength
            expect(inspection).to eq(
              %({ category_name: "Appliances", products_by_sku: { "EMDL-2934" => { id: 4, name: "Jordan Air" }, "KDS-3912" => { id: 8, name: "Chevy Impala" } }, number_of_products: 2 }),
            )
            # rubocop:enable Metrics/LineLength
          end
        end

        context "given as_single_line: false" do
          it "returns a representation of the array across multiple lines" do
            value_to_inspect = {
              # rubocop:disable Style/HashSyntax
              :category_name => "Appliances",
              :products_by_sku => {
                "EMDL-2934" => { :id => 4, :name => "George Foreman Grill" },
                "KDS-3912" => { :id => 8, :name => "Magic Bullet" },
              },
              :number_of_products => 2,
              # rubocop:enable Style/HashSyntax
            }
            inspection = described_class.inspect(
              value_to_inspect,
              as_single_line: false,
            )
            expect(inspection).to eq(<<~INSPECTION.rstrip)
              {
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
              }
            INSPECTION
          end
        end
      end

      context "which is empty" do
        context "given as_single_line: true" do
          it "returns a representation of the array on a single line" do
            inspection = described_class.inspect({}, as_single_line: true)
            expect(inspection).to eq(%({}))
          end
        end

        context "given as_single_line: false" do
          it "returns a representation of the array on a single line" do
            inspection = described_class.inspect({}, as_single_line: false)
            expect(inspection).to eq(%({}))
          end
        end
      end
    end

    context "given a class" do
      context "given as_single_line: true" do
        it "returns a representation of the object on a single line" do
          inspection = described_class.inspect(
            SuperDiff::Test::Person,
            as_single_line: true,
          )
          expect(inspection).to eq("SuperDiff::Test::Person")
        end
      end

      context "given as_single_line: false" do
        it "returns a representation of the object on a single line" do
          inspection = described_class.inspect(
            SuperDiff::Test::Person,
            as_single_line: false,
          )
          expect(inspection).to eq("SuperDiff::Test::Person")
        end
      end
    end

    context "given a custom object" do
      context "containing only primitive values" do
        context "given as_single_line: true" do
          it "returns a representation of the object on a single line" do
            inspection = described_class.inspect(
              SuperDiff::Test::Person.new(name: "Doc", age: 58),
              as_single_line: true,
            )
            expect(inspection).to eq(
              %(#<SuperDiff::Test::Person name: "Doc", age: 58>),
            )
          end
        end

        context "given as_single_line: false" do
          it "returns a representation of the object across multiple lines" do
            inspection = described_class.inspect(
              SuperDiff::Test::Person.new(name: "Doc", age: 58),
              as_single_line: false,
            )
            expect(inspection).to eq(<<~INSPECTION.rstrip)
              #<SuperDiff::Test::Person {
                name: "Doc",
                age: 58
              }>
            INSPECTION
          end
        end
      end

      context "containing other custom objects" do
        context "given as_single_line: true" do
          it "returns a representation of the object on a single line" do
            inspection = described_class.inspect(
              SuperDiff::Test::Customer.new(
                name: "Marty McFly",
                shipping_address: SuperDiff::Test::ShippingAddress.new(
                  line_1: "123 Main St.",
                  line_2: "",
                  city: "Hill Valley",
                  state: "CA",
                  zip: "90382",
                ),
                phone: "111-222-3333",
              ),
              as_single_line: true,
            )
            expect(inspection).to eq(
              # rubocop:disable Metrics/LineLength
              %(#<SuperDiff::Test::Customer name: "Marty McFly", shipping_address: #<SuperDiff::Test::ShippingAddress line_1: "123 Main St.", line_2: "", city: "Hill Valley", state: "CA", zip: "90382">, phone: "111-222-3333">),
              # rubocop:enable Metrics/LineLength
            )
          end
        end

        context "given as_single_line: false" do
          it "returns a representation of the object across multiple lines" do
            inspection = described_class.inspect(
              SuperDiff::Test::Customer.new(
                name: "Marty McFly",
                shipping_address: SuperDiff::Test::ShippingAddress.new(
                  line_1: "123 Main St.",
                  line_2: "",
                  city: "Hill Valley",
                  state: "CA",
                  zip: "90382",
                ),
                phone: "111-222-3333",
              ),
              as_single_line: false,
            )
            expect(inspection).to eq(<<~INSPECTION.rstrip)
              #<SuperDiff::Test::Customer {
                name: "Marty McFly",
                shipping_address: #<SuperDiff::Test::ShippingAddress {
                  line_1: "123 Main St.",
                  line_2: "",
                  city: "Hill Valley",
                  state: "CA",
                  zip: "90382"
                }>,
                phone: "111-222-3333"
              }>
            INSPECTION
          end
        end
      end
    end

    context "given a non-custom object" do
      context "containing only primitive values" do
        context "given as_single_line: true" do
          it "returns a representation of the object on a single line" do
            inspection = described_class.inspect(
              SuperDiff::Test::Item.new(
                name: "mac and cheese",
                quantity: 2,
              ),
              as_single_line: true,
            )
            expect(inspection).to match(
              # rubocop:disable Metrics/LineLength
              /\A#<SuperDiff::Test::Item:0x[a-z0-9]+ @name="mac and cheese", @quantity=2>\Z/,
              # rubocop:enable Metrics/LineLength
            )
          end
        end

        context "given as_single_line: false" do
          it "returns a representation of the object across multiple lines" do
            inspection = described_class.inspect(
              SuperDiff::Test::Item.new(
                name: "mac and cheese",
                quantity: 2,
              ),
              as_single_line: false,
            )
            regexp = <<~INSPECTION.rstrip
              #<SuperDiff::Test::Item:0x[a-z0-9]+ \\{
                @name="mac and cheese",
                @quantity=2
              \\}>
            INSPECTION
            expect(inspection).to match(/\A#{regexp}\Z/)
          end
        end
      end

      context "containing other custom objects" do
        context "given as_single_line: true" do
          it "returns a representation of the object on a single line" do
            inspection = described_class.inspect(
              SuperDiff::Test::Order.new([
                SuperDiff::Test::Item.new(name: "ham", quantity: 1),
                SuperDiff::Test::Item.new(name: "eggs", quantity: 2),
                SuperDiff::Test::Item.new(name: "cheese", quantity: 1),
              ]),
              as_single_line: true,
            )
            expect(inspection).to match(
              # rubocop:disable Metrics/LineLength
              /\A#<SuperDiff::Test::Order:0x[a-z0-9]+ @items=\[#<SuperDiff::Test::Item:0x[a-z0-9]+ @name="ham", @quantity=1>, #<SuperDiff::Test::Item:0x[a-z0-9]+ @name="eggs", @quantity=2>, #<SuperDiff::Test::Item:0x[a-z0-9]+ @name="cheese", @quantity=1>\]>\Z/,
              # rubocop:enable Metrics/LineLength
            )
          end
        end

        context "given as_single_line: false" do
          it "returns a representation of the object across multiple lines" do
            inspection = described_class.inspect(
              SuperDiff::Test::Order.new([
                SuperDiff::Test::Item.new(name: "ham", quantity: 1),
                SuperDiff::Test::Item.new(name: "eggs", quantity: 2),
                SuperDiff::Test::Item.new(name: "cheese", quantity: 1),
              ]),
              as_single_line: false,
            )
            regexp = <<~INSPECTION.rstrip
              #<SuperDiff::Test::Order:0x[a-z0-9]+ \\{
                @items=\\[
                  #<SuperDiff::Test::Item:0x[a-z0-9]+ \\{
                    @name="ham",
                    @quantity=1
                  \\}>,
                  #<SuperDiff::Test::Item:0x[a-z0-9]+ \\{
                    @name="eggs",
                    @quantity=2
                  \\}>,
                  #<SuperDiff::Test::Item:0x[a-z0-9]+ \\{
                    @name="cheese",
                    @quantity=1
                  \\}>
                \\]
              }>
            INSPECTION
            expect(inspection).to match(/\A#{regexp}\Z/)
          end
        end
      end

      context "which is empty" do
        context "given as_single_line: true" do
          it "returns a representation of the array on a single line" do
            inspection = described_class.inspect(
              SuperDiff::Test::EmptyClass.new,
              as_single_line: true,
            )
            expect(inspection).to match(
              /#<SuperDiff::Test::EmptyClass:0x[a-z0-9]+>/
            )
          end
        end

        context "given as_single_line: false" do
          it "returns a representation of the array on a single line" do
            inspection = described_class.inspect(
              SuperDiff::Test::EmptyClass.new,
              as_single_line: false,
            )
            expect(inspection).to match(
              /#<SuperDiff::Test::EmptyClass:0x[a-z0-9]+>/
            )
          end
        end
      end
    end

    context "given a hash-including-<something>" do
      context "given as_single_line: true" do
        it "returns a representation of the object on a single line" do
          inspection = described_class.inspect(
            a_hash_including(foo: "bar", baz: "qux"),
            as_single_line: true,
          )

          expect(inspection).to eq(
            %(#<a hash including (foo: "bar", baz: "qux")>),
          )
        end
      end

      context "given as_single_line: false" do
        it "returns a representation of the object across multiple lines" do
          inspection = described_class.inspect(
            a_hash_including(foo: "bar", baz: "qux"),
            as_single_line: false,
          )

          expect(inspection).to eq(<<~INSPECTION.rstrip)
            #<a hash including (
              foo: "bar",
              baz: "qux"
            )>
          INSPECTION
        end
      end
    end

    context "given a collection-including-<something>" do
      context "given as_single_line: true" do
        it "returns a representation of the object on a single line" do
          inspection = described_class.inspect(
            a_collection_including(1, 2, 3),
            as_single_line: true,
          )

          expect(inspection).to eq(
            %(#<a collection including (1, 2, 3)>),
          )
        end
      end

      context "given as_single_line: false" do
        it "returns a representation of the object across multiple lines" do
          inspection = described_class.inspect(
            a_collection_including(1, 2, 3),
            as_single_line: false,
          )

          expect(inspection).to eq(<<~INSPECTION.rstrip)
            #<a collection including (
              1,
              2,
              3
            )>
          INSPECTION
        end
      end
    end

    context "given a fuzzy object" do
      context "given as_single_line: true" do
        it "returns a representation of the object on a single line" do
          inspection = described_class.inspect(
            an_object_having_attributes(foo: "bar", baz: "qux"),
            as_single_line: true,
          )

          expect(inspection).to eq(
            %(#<an object having attributes (foo: "bar", baz: "qux")>),
          )
        end
      end

      context "given as_single_line: false" do
        it "returns a representation of the object across multiple lines" do
          inspection = described_class.inspect(
            an_object_having_attributes(foo: "bar", baz: "qux"),
            as_single_line: false,
          )

          expect(inspection).to eq(<<~INSPECTION.rstrip)
            #<an object having attributes (
              foo: "bar",
              baz: "qux"
            )>
          INSPECTION
        end
      end
    end

    context "given a collection-containing-exactly-<something>" do
      context "given as_single_line: true" do
        it "returns a representation of the object on a single line" do
          inspection = described_class.inspect(
            a_collection_containing_exactly("foo", "bar", "baz"),
            as_single_line: true,
          )

          expect(inspection).to eq(
            %(#<a collection containing exactly ("foo", "bar", "baz")>),
          )
        end
      end

      context "given as_single_line: false" do
        it "returns a representation of the object across multiple lines" do
          inspection = described_class.inspect(
            a_collection_containing_exactly("foo", "bar", "baz"),
            as_single_line: false,
          )

          expect(inspection).to eq(<<~INSPECTION.rstrip)
            #<a collection containing exactly (
              "foo",
              "bar",
              "baz"
            )>
          INSPECTION
        end
      end
    end

    context "given a Double" do
      context "that is anonymous" do
        context "given as_single_line: true" do
          it "returns a representation of the object on a single line" do
            inspection = described_class.inspect(
              double(foo: "bar", baz: "qux"),
              as_single_line: true,
            )

            expect(inspection).to eq("#<Double (anonymous)>")
          end
        end

        context "given as_single_line: false" do
          it "returns a representation of the object across multiple lines" do
            inspection = described_class.inspect(
              double(foo: "bar", baz: "qux"),
              as_single_line: false,
            )

            expect(inspection).to eq("#<Double (anonymous)>")
          end
        end
      end
    end

    context "given an ActiveRecord object", active_record: true do
      context "given as_single_line: true" do
        it "returns a representation of the object on a single line" do
          inspection = described_class.inspect(
            SuperDiff::Test::Models::ActiveRecord::Person.new(
              name: "Elliot",
              age: 31,
            ),
            as_single_line: true,
          )

          expect(inspection).to eq(
            %(#<SuperDiff::Test::Models::ActiveRecord::Person id: nil, age: 31, name: "Elliot">)
          )
        end
      end

      context "given as_single_line: false" do
        it "returns a representation of the object across multiple lines" do
          inspection = described_class.inspect(
            SuperDiff::Test::Models::ActiveRecord::Person.new(
              name: "Elliot",
              age: 31,
            ),
            as_single_line: false,
          )

          expect(inspection).to eq(<<~INSPECTION.rstrip)
            #<SuperDiff::Test::Models::ActiveRecord::Person {
              id: nil,
              age: 31,
              name: "Elliot"
            }>
          INSPECTION
        end
      end
    end

    context "given an ActiveRecord::Relation object", active_record: true do
      context "given as_single_line: true" do
        it "returns a representation of the Relation on a single line" do
          SuperDiff::Test::Models::ActiveRecord::Person.create!(
            name: "Marty",
            age: 19,
          )
          SuperDiff::Test::Models::ActiveRecord::Person.create!(
            name: "Jennifer",
            age: 17,
          )

          inspection = described_class.inspect(
            SuperDiff::Test::Models::ActiveRecord::Person.all,
            as_single_line: true,
          )

          expect(inspection).to eq(
            %(#<ActiveRecord::Relation [#<SuperDiff::Test::Models::ActiveRecord::Person id: 1, age: 19, name: "Marty">, #<SuperDiff::Test::Models::ActiveRecord::Person id: 2, age: 17, name: "Jennifer">]>)
          )
        end
      end

      context "given as_single_line: false" do
        it "returns a representation of the Relation across multiple lines" do
          SuperDiff::Test::Models::ActiveRecord::Person.create!(
            name: "Marty",
            age: 19,
          )
          SuperDiff::Test::Models::ActiveRecord::Person.create!(
            name: "Jennifer",
            age: 17,
          )

          inspection = described_class.inspect(
            SuperDiff::Test::Models::ActiveRecord::Person.all,
            as_single_line: false,
          )

          expect(inspection).to eq(<<~INSPECTION.rstrip)
            #<ActiveRecord::Relation [
              #<SuperDiff::Test::Models::ActiveRecord::Person {
                id: 1,
                age: 19,
                name: "Marty"
              }>,
              #<SuperDiff::Test::Models::ActiveRecord::Person {
                id: 2,
                age: 17,
                name: "Jennifer"
              }>
            ]>
          INSPECTION
        end
      end
    end

    context "given a HashWithIndifferentAccess", active_record: true do
      context "given as_single_line: true" do
        it "returns a representation of the object on a single line" do
          inspection = described_class.inspect(
            HashWithIndifferentAccess.new({
              line_1: "123 Main St.",
              city: "Hill Valley",
              state: "CA",
              zip: "90382",
            }),
            as_single_line: true,
          )

          expect(inspection).to eq(
            %(#<HashWithIndifferentAccess { "line_1" => "123 Main St.", "city" => "Hill Valley", "state" => "CA", "zip" => "90382" }>)
          )
        end
      end

      context "given as_single_line: false" do
        it "returns a representation of the object across multiple lines" do
          inspection = described_class.inspect(
            HashWithIndifferentAccess.new({
              line_1: "123 Main St.",
              city: "Hill Valley",
              state: "CA",
              zip: "90382",
            }),
            as_single_line: false,
          )

          expect(inspection).to eq(<<~INSPECTION.rstrip)
            #<HashWithIndifferentAccess {
              "line_1" => "123 Main St.",
              "city" => "Hill Valley",
              "state" => "CA",
              "zip" => "90382"
            }>
          INSPECTION
        end
      end
    end

    context "given a combination of all kinds of values" do
      context "given as_single_line: true" do
        it "returns a representation of the object on a single line" do
          inspection = described_class.inspect(
            {
              state: :down,
              errors: [
                "Container A-234 is partially damaged",
                "Vessel B042 was attacked by raccoons",
                "Product FDK-3429 is out of stock",
              ],
              mission_critical: true,
              serviceable: false,
              outstanding_orders: [
                SuperDiff::Test::Order.new([
                  SuperDiff::Test::Item.new(name: "ham", quantity: 1),
                  SuperDiff::Test::Item.new(name: "eggs", quantity: 2),
                  SuperDiff::Test::Item.new(name: "cheese", quantity: 1),
                ]),
              ],
              customers: [
                SuperDiff::Test::Customer.new(
                  name: "Marty McFly",
                  shipping_address: SuperDiff::Test::ShippingAddress.new(
                    line_1: "123 Baltic Ave.",
                    line_2: "",
                    city: "Hill Valley",
                    state: "CA",
                    zip: "90382",
                  ),
                  phone: "111-111-1111",
                ),
                SuperDiff::Test::Customer.new(
                  name: "Doc Brown",
                  shipping_address: SuperDiff::Test::ShippingAddress.new(
                    line_1: "456 Park Place",
                    line_2: "",
                    city: "Beverly Hills",
                    state: "CA",
                    zip: "90210",
                  ),
                  phone: "222-222-2222",
                ),
              ],
            },
            as_single_line: true,
          )
          expect(inspection).to match(
            # rubocop:disable Metrics/LineLength
            /\A\{ state: :down, errors: \["Container A-234 is partially damaged", "Vessel B042 was attacked by raccoons", "Product FDK-3429 is out of stock"\], mission_critical: true, serviceable: false, outstanding_orders: \[#<SuperDiff::Test::Order:0x[a-z0-9]+ @items=\[#<SuperDiff::Test::Item:0x[a-z0-9]+ @name="ham", @quantity=1>, #<SuperDiff::Test::Item:0x[a-z0-9]+ @name="eggs", @quantity=2>, #<SuperDiff::Test::Item:0x[a-z0-9]+ @name="cheese", @quantity=1>\]>\], customers: \[#<SuperDiff::Test::Customer name: "Marty McFly", shipping_address: #<SuperDiff::Test::ShippingAddress line_1: "123 Baltic Ave.", line_2: "", city: "Hill Valley", state: "CA", zip: "90382">, phone: "111-111-1111">, #<SuperDiff::Test::Customer name: "Doc Brown", shipping_address: #<SuperDiff::Test::ShippingAddress line_1: "456 Park Place", line_2: "", city: "Beverly Hills", state: "CA", zip: "90210">, phone: "222-222-2222">\] \}\Z/,
            # rubocop:enable Metrics/LineLength
          )
        end
      end

      context "given as_single_line: false" do
        it "returns a representation of the object across multiple lines" do
          inspection = described_class.inspect(
            {
              state: :down,
              errors: [
                "Container A-234 is partially damaged",
                "Vessel B042 was attacked by raccoons",
                "Product FDK-3429 is out of stock",
              ],
              mission_critical: true,
              serviceable: false,
              outstanding_orders: [
                SuperDiff::Test::Order.new([
                  SuperDiff::Test::Item.new(name: "ham", quantity: 1),
                  SuperDiff::Test::Item.new(name: "eggs", quantity: 2),
                  SuperDiff::Test::Item.new(name: "cheese", quantity: 1),
                ]),
              ],
              customers: [
                SuperDiff::Test::Customer.new(
                  name: "Marty McFly",
                  shipping_address: SuperDiff::Test::ShippingAddress.new(
                    line_1: "123 Baltic Ave.",
                    line_2: "",
                    city: "Hill Valley",
                    state: "CA",
                    zip: "90382",
                  ),
                  phone: "111-111-1111",
                ),
                SuperDiff::Test::Customer.new(
                  name: "Doc Brown",
                  shipping_address: SuperDiff::Test::ShippingAddress.new(
                    line_1: "456 Park Place",
                    line_2: "",
                    city: "Beverly Hills",
                    state: "CA",
                    zip: "90210",
                  ),
                  phone: "222-222-2222",
                ),
              ],
            },
            as_single_line: false,
          )
          regexp = <<~INSPECTION.rstrip
            \\{
              state: :down,
              errors: \\[
                "Container A-234 is partially damaged",
                "Vessel B042 was attacked by raccoons",
                "Product FDK-3429 is out of stock"
              \\],
              mission_critical: true,
              serviceable: false,
              outstanding_orders: \\[
                #<SuperDiff::Test::Order:0x[a-z0-9]+ \\{
                  @items=\\[
                    #<SuperDiff::Test::Item:0x[a-z0-9]+ \\{
                      @name="ham",
                      @quantity=1
                    \\}>,
                    #<SuperDiff::Test::Item:0x[a-z0-9]+ \\{
                      @name="eggs",
                      @quantity=2
                    \\}>,
                    #<SuperDiff::Test::Item:0x[a-z0-9]+ \\{
                      @name="cheese",
                      @quantity=1
                    \\}>
                  \\]
                \\}>
              \\],
              customers: \\[
                #<SuperDiff::Test::Customer \\{
                  name: "Marty McFly",
                  shipping_address: #<SuperDiff::Test::ShippingAddress \\{
                    line_1: "123 Baltic Ave.",
                    line_2: "",
                    city: "Hill Valley",
                    state: "CA",
                    zip: "90382"
                  \\}>,
                  phone: "111-111-1111"
                \\}>,
                #<SuperDiff::Test::Customer \\{
                  name: "Doc Brown",
                  shipping_address: #<SuperDiff::Test::ShippingAddress \\{
                    line_1: "456 Park Place",
                    line_2: "",
                    city: "Beverly Hills",
                    state: "CA",
                    zip: "90210"
                  \\}>,
                  phone: "222-222-2222"
                \\}>
              \\]
            \\}
          INSPECTION
          expect(inspection).to match(/\A#{regexp}\Z/)
        end
      end
    end
  end

  context "given a data structure that refers to itself somewhere inside of it" do
    context "given as_single_line: true" do
      it "replaces the reference with ∙∙∙" do
        value = ["a", "b", "c"]
        value.insert(1, value)
        inspection = described_class.inspect(value, as_single_line: true)
        expect(inspection).to eq(%(["a", ∙∙∙, "b", "c"]))
      end
    end

    context "given as_single_line: false" do
      it "replaces the reference with ∙∙∙" do
        value = ["a", "b", "c"]
        value.insert(1, value)
        inspection = described_class.inspect(value, as_single_line: false)
        expect(inspection).to eq(<<~INSPECTION.rstrip)
          [
            "a",
            ∙∙∙,
            "b",
            "c"
          ]
        INSPECTION
      end
    end
  end

  def colorize(*args, **opts, &block)
    SuperDiff::Helpers.style(*args, **opts, &block).to_s.chomp
  end
end
