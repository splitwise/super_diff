require "spec_helper"

RSpec.describe SuperDiff, type: :unit do
  describe ".inspect_object" do
    context "given as_lines: false" do
      subject(:output) do
        described_class.inspect_object(object, as_lines: false)
      end

      context "given an anonymous Data object" do
        let(:object) { Data.define(:x, :y).new(1, 2) }

        it "shows the data" do
          expect(output).to eq("#<data  x: 1, y: 2>")
        end
      end

      context "given a named Data object" do
        let(:object) { SuperDiff::Test::Point.new(1, 2) }

        it "shows the data" do
          expect(output).to eq("#<data SuperDiff::Test::Point x: 1, y: 2>")
        end
      end

      context "given a Data object that defines #attributes_for_super_diff" do
        let(:klass) do
          Data.define(:x, :y) do
            def attributes_for_super_diff
              { beep: :boop }
            end
          end
        end
        let(:object) { klass.new(1, 2) }

        it "uses the custom attributes" do
          expect(output).to start_with("#<#<Class:0x").and end_with(
                  "beep: :boop>"
                )
        end
      end
    end

    context "given as_lines: true" do
      subject(:tiered_lines) do
        described_class.inspect_object(
          object,
          as_lines: true,
          type: :noop,
          indentation_level: 1
        )
      end

      context "given an anonymous Data object" do
        let(:object) { Data.define(:x, :y).new(1, 2) }

        it "shows the data" do
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                value: "#<data  {",
                collection_bookend: :open
              ),
              an_object_having_attributes(
                prefix: "x: ",
                value: "1",
                add_comma: true
              ),
              an_object_having_attributes(
                prefix: "y: ",
                value: "2",
                add_comma: false
              ),
              an_object_having_attributes(
                value: "}>",
                collection_bookend: :close
              )
            ]
          )
        end
      end

      context "given a named Data object" do
        let(:object) { SuperDiff::Test::Point.new(1, 2) }

        it "shows the data" do
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                value: "#<data SuperDiff::Test::Point {",
                collection_bookend: :open
              ),
              an_object_having_attributes(
                prefix: "x: ",
                value: "1",
                add_comma: true
              ),
              an_object_having_attributes(
                prefix: "y: ",
                value: "2",
                add_comma: false
              ),
              an_object_having_attributes(
                value: "}>",
                collection_bookend: :close
              )
            ]
          )
        end
      end

      context "given a Data object that defines #attributes_for_super_diff" do
        let(:klass) do
          Data.define(:x, :y) do
            def attributes_for_super_diff
              { beep: :boop }
            end
          end
        end
        let(:object) { klass.new(1, 2) }

        it "uses the custom attributes" do
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                value: /\A#<#<Class:0x.*> {/,
                collection_bookend: :open
              ),
              an_object_having_attributes(
                prefix: "beep: ",
                value: ":boop",
                add_comma: false
              ),
              an_object_having_attributes(
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
