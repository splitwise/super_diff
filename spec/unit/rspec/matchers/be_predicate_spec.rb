require "spec_helper"

RSpec.describe "RSpec's be_predicate matcher" do
  describe "#description" do
    context 'given "be_<predicate>"' do
      it "returns the correct output" do
        expect(be_famous.description).to eq(
          "return true for `famous?` or `famouss?`",
        )
      end
    end

    context 'given "be_a_<predicate>"' do
      it "returns the correct output" do
        expect(be_a_big_big_star.description).to eq(
          "return true for `big_big_star?` or `big_big_stars?`",
        )
      end
    end

    context 'given "be_an_<predicate>"' do
      it "returns the correct output" do
        expect(be_an_open_book.description).to eq(
          "return true for `open_book?` or `open_books?`",
        )
      end
    end
  end
end
