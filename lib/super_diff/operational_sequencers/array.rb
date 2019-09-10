module SuperDiff
  module OperationalSequencers
    class Array < Base
      def self.applies_to?(expected, actual)
        expected.is_a?(::Array) && actual.is_a?(::Array)
      end

      def call
        Diff::LCS.traverse_balanced(expected, actual, lcs_callbacks)
        lcs_callbacks.operations
      end

      private

      def lcs_callbacks
        @_lcs_callbacks ||= LcsCallbacks.new(
          expected: expected,
          actual: actual,
          extra_operational_sequencer_classes: extra_operational_sequencer_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes,
        )
      end

      class LcsCallbacks
        attr_reader :operations

        def initialize(
          expected:,
          actual:,
          extra_operational_sequencer_classes:,
          extra_diff_formatter_classes:
        )
          @expected = expected
          @actual = actual
          @extra_operational_sequencer_classes =
            extra_operational_sequencer_classes
          @extra_diff_formatter_classes = extra_diff_formatter_classes

          @operations = OperationSequences::Array.new([])
        end

        def match(event)
          operations << ::SuperDiff::Operations::UnaryOperation.new(
            name: :noop,
            collection: actual,
            key: event.new_position,
            value: event.new_element,
            index: event.new_position,
            index_in_collection: actual.index(event.new_element),
          )
        end

        def discard_a(event)
          operations << ::SuperDiff::Operations::UnaryOperation.new(
            name: :delete,
            collection: expected,
            key: event.old_position,
            value: event.old_element,
            index: event.old_position,
            index_in_collection: expected.index(event.old_element),
          )
        end

        def discard_b(event)
          operations << ::SuperDiff::Operations::UnaryOperation.new(
            name: :insert,
            collection: actual,
            key: event.new_position,
            value: event.new_element,
            index: event.new_position,
            index_in_collection: actual.index(event.new_element),
          )
        end

        def change(event)
          child_operations = sequence(event.old_element, event.new_element)

          if child_operations
            operations << ::SuperDiff::Operations::BinaryOperation.new(
              name: :change,
              left_collection: expected,
              right_collection: actual,
              left_key: event.old_position,
              right_key: event.new_position,
              left_value: event.old_element,
              right_value: event.new_element,
              left_index: event.old_position,
              right_index: event.new_position,
              child_operations: child_operations,
            )
          else
            operations << Operations::UnaryOperation.new(
              name: :delete,
              collection: expected,
              key: event.old_position,
              value: event.old_element,
              index: event.old_position,
              index_in_collection: expected.index(event.old_element),
            )
            operations << Operations::UnaryOperation.new(
              name: :insert,
              collection: actual,
              key: event.new_position,
              value: event.new_element,
              index: event.new_position,
              index_in_collection: actual.index(event.new_element),
            )
          end
        end

        private

        attr_reader :expected, :actual, :extra_operational_sequencer_classes,
          :extra_diff_formatter_classes

        def sequence(expected, actual)
          OperationalSequencer.call(
            expected: expected,
            actual: actual,
            extra_classes: extra_operational_sequencer_classes,
            extra_diff_formatter_classes: extra_diff_formatter_classes,
          )
        rescue NoOperationalSequencerAvailableError
          nil
        end
      end
    end
  end
end
