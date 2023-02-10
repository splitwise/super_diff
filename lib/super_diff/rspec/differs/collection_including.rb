module SuperDiff
  module RSpec
    module Differs
      class CollectionIncluding < SuperDiff::Differs::Array
        def self.applies_to?(expected, actual)
          (
            SuperDiff::RSpec.a_collection_including_something?(expected) ||
              SuperDiff::RSpec.array_including_something?(expected)
          ) && actual.is_a?(::Array)
        end

        private

        def operation_tree_builder_class
          OperationTreeBuilders::CollectionIncluding
        end
      end
    end
  end
end
