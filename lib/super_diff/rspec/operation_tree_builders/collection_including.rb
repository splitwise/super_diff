module SuperDiff
  module RSpec
    module OperationTreeBuilders
      class CollectionIncluding < SuperDiff::OperationTreeBuilders::Array
        def self.applies_to?(expected, actual)
          (
            SuperDiff::RSpec.a_collection_including_something?(expected) ||
              SuperDiff::RSpec.array_including_something?(expected)
          ) && actual.is_a?(::Array)
        end

        def initialize(expected:, actual:, **rest)
          super

          @expected = actual_with_extra_items_in_expected_at_end
        end

        private

        def actual_with_extra_items_in_expected_at_end
          value =
            if SuperDiff::RSpec.a_collection_including_something?(expected)
              expected.expecteds
            else
              expected.instance_variable_get(:@expected)
            end
          actual + (value - actual)
        end
      end
    end
  end
end
