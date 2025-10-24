# frozen_string_literal: true

module SuperDiff
  module Basic
    module OperationTreeBuilders
      class Hash < Core::AbstractOperationTreeBuilder
        def self.applies_to?(expected, actual)
          expected.is_a?(::Hash) && actual.is_a?(::Hash)
        end

        protected

        def unary_operations
          unary_operations_using_longest_common_key_subsequence
        end

        def build_operation_tree
          OperationTrees::Hash.new([])
        end

        private

        def unary_operations_using_longest_common_key_subsequence
          aks = actual.keys
          eks = expected.keys

          operations = []
          lcs_callbacks = LCSCallbacks.new(
            operations: operations,
            expected: expected,
            actual: actual,
            should_add_noop_operation: method(:should_add_noop_operation?)
          )
          Diff::LCS.traverse_sequences(eks, aks, lcs_callbacks)

          operations
        end

        class LCSCallbacks
          extend AttrExtras.mixin

          pattr_initialize %i[operations! expected! actual! should_add_noop_operation!]
          public :operations

          def discard_a(event)
            # This key is in `expected`, but may also be in `actual`.
            key = event.old_element

            # We want the diff to match the key order of `actual` as much as
            # possible, so if this is also a key in `actual` that's just being
            # reordered, don't add any operations now. The change or noop will
            # be added later.
            return if actual.include?(key)

            operations << Core::UnaryOperation.new(
              name: :delete,
              collection: expected,
              key: key,
              value: expected[key],
              index: event.old_position
            )
          end

          def discard_b(event)
            # This key is in `actual`, but may also be in `expected`.

            key = event.new_element
            handle_operation_on_key_in_actual(key, event)
          end

          def match(event)
            # This key is part of the longest common subsequence.

            key = event.old_element
            handle_operation_on_key_in_actual(key, event)
          end

          private

          def handle_operation_on_key_in_actual(key, event)
            if should_add_noop_operation.call(key)
              operations << Core::UnaryOperation.new(
                name: :noop,
                collection: actual,
                key: key,
                value: actual[key],
                index: event.new_position
              )
            else
              # If the key is present in both `actual` and `expected`
              # but the values don't match, create a `delete` operation
              # just before the `insert`.
              # (This condition will always be true for `match` events.)
              if expected.include?(key)
                operations << Core::UnaryOperation.new(
                  name: :delete,
                  collection: expected,
                  key: key,
                  value: expected[key],
                  index: event.old_position
                )
              end

              operations << Core::UnaryOperation.new(
                name: :insert,
                collection: actual,
                key: key,
                value: actual[key],
                index: event.new_position
              )
            end
          end
        end

        def should_add_noop_operation?(key)
          expected.include?(key) && expected[key] == actual[key]
        end

        def all_keys
          actual.keys | expected.keys
        end
      end
    end
  end
end
