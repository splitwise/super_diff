require "spec_helper"

RSpec.describe SuperDiff::Helpers do
  shared_examples 'helper tests' do
    describe "with_slice_of_array_replaced" do
      context "if the given range covers the whole array" do
        it "returns a copy of the array replaced with the replacement" do
          updated_array = helper.with_slice_of_array_replaced(
            [1, 2, 3],
            0..2,
            :x,
          )

          expect(updated_array).to eq([:x])
        end
      end

      context "if the given range is at the start of the array" do
        it "returns the selected slice replaced with the replacement + the rest" do
          updated_array = helper.with_slice_of_array_replaced(
            [1, 2, 3, 4, 5],
            0..2,
            :x,
          )

          expect(updated_array).to eq([:x, 4, 5])
        end
      end

      context "if the given range is at the end of the array" do
        it "returns the selected slice replaced with the replacement + the rest" do
          updated_array = helper.with_slice_of_array_replaced(
            [1, 2, 3, 4, 5],
            2..4,
            :x,
          )

          expect(updated_array).to eq([1, 2, :x])
        end
      end
    end
  end

  describe 'as class methods' do
    let(:helper) { described_class }

    include_examples 'helper tests'
  end

  describe 'as instance methods' do
    let(:helper) { described_class }
    let(:helper) do
      mod = described_class
      Object.new.tap do |helper|
        helper.singleton_class.class_eval { include mod }
      end
    end

    include_examples 'helper tests'
  end
end
