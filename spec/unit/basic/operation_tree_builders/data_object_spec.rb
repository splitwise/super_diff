require "spec_helper"

RSpec.describe SuperDiff, type: :unit do
  describe ".diff" do
    subject(:diff) { described_class.diff(a, b) }

    context "when given two Data objects of the same class" do
      let(:a) { SuperDiff::Test::Point.new(1, 2) }
      let(:b) { SuperDiff::Test::Point.new(1, 3) }

      it "diffs their member attributes" do
        expected_output =
          SuperDiff::Core::Helpers
            .style(color_enabled: true) do
              plain_line "  #<SuperDiff::Test::Point {"
              plain_line "    x: 1,"
              expected_line "-   y: 2"
              actual_line "+   y: 3"
              plain_line "  }>"
            end
            .to_s
            .chomp

        expect(diff).to eq(expected_output)
      end

      context "when the Data class defines #attributes_for_super_diff" do
        let(:klass) do
          Class.new(Data.define(:attribute)) do
            def self.to_s = "TestClass"

            def attributes_for_super_diff
              { attribute: :does_not_matter }
            end
          end
        end

        let(:a) { klass.new(1) }
        let(:b) { klass.new(2) }

        it "diffs their member attributes" do
          expected_output =
            SuperDiff::Core::Helpers
              .style(color_enabled: true) do
                plain_line "  #<TestClass {"
                expected_line "-   attribute: 1"
                actual_line "+   attribute: 2"
                plain_line "  }>"
              end
              .to_s
              .chomp

          expect(diff).to eq(expected_output)
        end
      end
    end

    context "when given two Data objects of different classes" do
      let(:a) { SuperDiff::Test::Point.new(1, 2) }
      let(:b) { Data.define(:one, :two).new(1, 2) }

      it "raises" do
        expect { SuperDiff.diff(a, b) }.to raise_error(
          SuperDiff::Core::NoDifferAvailableError
        )
      end
    end

    context "when given a Data object and a hash" do
      let(:a) { Data.define(:one, :two).new(1, 2) }
      let(:b) { { one: 1, two: 2 } }

      it "raises" do
        expect { SuperDiff.diff(a, b) }.to raise_error(
          SuperDiff::Core::NoDifferAvailableError
        )
      end
    end
  end
end
