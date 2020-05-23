module SuperDiff
  module RSpec
    module Differs
      class ObjectHavingAttributes < SuperDiff::Differs::DefaultObject
        def self.applies_to?(expected, _actual)
          SuperDiff::RSpec.an_object_having_some_attributes?(expected)
        end

        private

        def operation_tree_builder_class
          OperationTreeBuilders::ObjectHavingAttributes
        end
      end
    end
  end
end
