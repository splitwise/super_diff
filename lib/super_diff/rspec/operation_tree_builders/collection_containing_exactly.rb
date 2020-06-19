module SuperDiff
  module RSpec
    module OperationTreeBuilders
      class CollectionContainingExactly < SuperDiff::OperationTreeBuilders::Base
        def self.applies_to?(expected, actual)
          SuperDiff::RSpec.a_collection_containing_exactly_something?(expected) &&
            actual.is_a?(::Array)
        end

        def initialize(actual:, **)
          super
          populate_pairings_maximizer_in_expected_with(actual)
        end

        protected

        def unary_operations
          operations = []

          (0...actual.length).reject do |index|
            indexes_in_actual_but_not_in_expected.include?(index)
          end.each do |index|
            add_noop_to(operations, index)
          end

          indexes_in_actual_but_not_in_expected.each do |index|
            add_insert_to(operations, index)
          end

          indexes_in_expected_but_not_in_actual.each do |index|
            add_delete_to(operations, index)
          end

          operations
        end

        def build_operation_tree
          OperationTrees::Array.new([])
        end

        private

        def populate_pairings_maximizer_in_expected_with(actual)
          expected.matches?(actual)
        end

        def add_noop_to(operations, index)
          value = actual[index]
          operations << ::SuperDiff::Operations::UnaryOperation.new(
            name: :noop,
            collection: collection,
            key: index,
            value: value,
            index: index,
          )
        end

        def add_delete_to(operations, index)
          value = expected.expected[index]
          operations << ::SuperDiff::Operations::UnaryOperation.new(
            name: :delete,
            collection: collection,
            key: index,
            value: value,
            index: index,
          )
        end

        def add_insert_to(operations, index)
          value = actual[index]
          operations << ::SuperDiff::Operations::UnaryOperation.new(
            name: :insert,
            collection: collection,
            key: index,
            value: value,
            index: index,
          )
        end

        def collection
          actual + values_in_expected_but_not_in_actual
        end

        def values_in_expected_but_not_in_actual
          indexes_in_expected_but_not_in_actual.map do |index|
            expected.expected[index]
          end
        end

        def indexes_in_actual_but_not_in_expected
          @indexes_in_actual_but_not_in_expected ||=
            pairings_maximizer_best_solution.unmatched_actual_indexes
        end

        def indexes_in_expected_but_not_in_actual
          pairings_maximizer_best_solution.unmatched_expected_indexes
        end

        def pairings_maximizer_best_solution
          expected.__send__(:best_solution)
        end
      end
    end
  end
end
