require "spec_helper"

RSpec.describe SuperDiff, type: :unit do
  describe ".inspect_object", "for RSpec matchers" do
    context "given a custom matcher" do
      let(:custom_matcher) do
        proc do |expected, &block_arg|
          declarations =
            proc do
              match do |actual|
                actual.is_a?(Integer) && actual >= 0 &&
                  (Math.sqrt(actual) % 1).zero?
              end
              description { "be a perfect square" }
            end
          RSpec::Matchers::DSL::Matcher.new(
            :be_a_square,
            declarations,
            RSpec::Matchers::DSL,
            *expected,
            &block_arg
          )
        end
      end

      context "given as_lines: false" do
        it "returns the matcher's description string" do
          string =
            described_class.inspect_object(
              custom_matcher.call(4),
              as_lines: false
            )
          expect(string).to eq("#<be a perfect square>")
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the matcher as multiple lines" do
          tiered_lines =
            described_class.inspect_object(
              custom_matcher.call(4),
              as_lines: true,
              type: :delete,
              indentation_level: 1
            )
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: "#<be a perfect square>"
              )
            ]
          )
        end
      end
    end

    context "given a built-in matcher" do
      let(:matcher) { be_a(Numeric) }

      context "given as_lines: false" do
        it "returns the matcher's description string" do
          string = described_class.inspect_object(matcher, as_lines: false)
          expect(string).to eq("#<be a kind of Numeric>")
        end
      end

      context "given as_lines: true" do
        it "returns an inspected version of the matcher as multiple lines" do
          tiered_lines =
            described_class.inspect_object(
              matcher,
              as_lines: true,
              type: :delete,
              indentation_level: 1
            )
          expect(tiered_lines).to match(
            [
              an_object_having_attributes(
                type: :delete,
                indentation_level: 1,
                value: "#<be a kind of Numeric>"
              )
            ]
          )
        end
      end
    end
  end
end
