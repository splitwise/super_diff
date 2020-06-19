module SuperDiff
  module OperationTreeBuilders
    class Array < Base
      def self.applies_to?(expected, actual)
        expected.is_a?(::Array) && actual.is_a?(::Array)
      end

      def call
        Diff::LCS.traverse_balanced(expected, actual, lcs_callbacks)
        operation_tree
      end

      private

      def lcs_callbacks
        @_lcs_callbacks ||= LcsCallbacks.new(
          operation_tree: operation_tree,
          expected: expected,
          actual: actual,
          compare: method(:compare),
        )
      end

      def operation_tree
        @_operation_tree ||= OperationTrees::Array.new([])
      end

      class LcsCallbacks
        extend AttrExtras.mixin

        pattr_initialize [:operation_tree!, :expected!, :actual!, :compare!]
        public :operation_tree

        def match(event)
          add_noop_operation(event)
        end

        def discard_a(event)
          add_delete_operation(event)
        end

        def discard_b(event)
          add_insert_operation(event)
        end

        def change(event)
          children = compare.(event.old_element, event.new_element)

          if children
            add_change_operation(event, children)
          else
            add_delete_operation(event)
            add_insert_operation(event)
          end
        end

        private

        def add_delete_operation(event)
          operation_tree << Operations::UnaryOperation.new(
            name: :delete,
            collection: expected,
            key: event.old_position,
            value: event.old_element,
            index: event.old_position,
          )
        end

        def add_insert_operation(event)
          operation_tree << Operations::UnaryOperation.new(
            name: :insert,
            collection: actual,
            key: event.new_position,
            value: event.new_element,
            index: event.new_position,
          )
        end

        def add_noop_operation(event)
          operation_tree << Operations::UnaryOperation.new(
            name: :noop,
            collection: actual,
            key: event.new_position,
            value: event.new_element,
            index: event.new_position,
          )
        end

        def add_change_operation(event, children)
          operation_tree << Operations::BinaryOperation.new(
            name: :change,
            left_collection: expected,
            right_collection: actual,
            left_key: event.old_position,
            right_key: event.new_position,
            left_value: event.old_element,
            right_value: event.new_element,
            left_index: event.old_position,
            right_index: event.new_position,
            children: children,
          )
        end
      end
    end
  end
end
