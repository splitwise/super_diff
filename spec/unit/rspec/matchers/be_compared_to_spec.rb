require "spec_helper"

RSpec.describe "RSpec's `be` matcher used with an operator" do
  describe "#description" do
    %i[== === =~].each do |operator|
      context "when the operator is #{operator}" do
        it "returns the correct output" do
          expect(be.public_send(operator, 2).description).to eq("#{operator} 2")
        end
      end
    end

    %i[< <= >= >].each do |operator|
      context "when the operator is #{operator}" do
        it "returns the correct output" do
          expect(be.public_send(operator, 2).description).to eq(
            "be #{operator} 2"
          )
        end
      end
    end
  end
end
