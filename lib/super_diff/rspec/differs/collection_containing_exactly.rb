module SuperDiff
  module RSpec
    module Differs
      class CollectionContainingExactly < SuperDiff::Differs::Array
        def self.applies_to?(expected, actual)
          SuperDiff::RSpec.a_collection_containing_exactly_something?(
            expected
          ) && actual.is_a?(::Array)
        end

        private

        def operation_tree_builder_class
          OperationTreeBuilders::CollectionContainingExactly
        end
      end
    end
  end
end
