module SuperDiff
  module RSpec
    module Differs
      class HashIncluding < SuperDiff::Differs::Hash
        def self.applies_to?(expected, actual)
          (
            SuperDiff::RSpec.a_hash_including_something?(expected) ||
              SuperDiff::RSpec.hash_including_something?(expected)
          ) && actual.is_a?(::Hash)
        end

        private

        def operation_tree_builder_class
          OperationTreeBuilders::HashIncluding
        end
      end
    end
  end
end
