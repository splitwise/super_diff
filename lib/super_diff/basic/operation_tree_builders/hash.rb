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
          unary_operations_using_variant_of_patience_algorithm
        end

        def build_operation_tree
          OperationTrees::Hash.new([])
        end

        private

        def unary_operations_using_variant_of_patience_algorithm
          operations = []
          aks = actual.keys
          eks = expected.keys
          previous_ei = nil

          # When diffing a hash, we're more interested in the 'actual' version
          # than the 'expected' version, because that's the ultimate truth.
          # Therefore, the diff is presented from the perspective of the 'actual'
          # hash, and we start off by looping over it.
          aks.each_with_index do |ak, ai|
            av = actual[ak]
            ev = expected[ak]
            # While we iterate over 'actual' in order, we jump all over
            # 'expected', trying to match up its keys with the keys in 'actual' as
            # much as possible.
            ei = eks.index(ak)

            if should_add_noop_operation?(ak)
              # (If we're here, it probably means that the key we're pointing to
              # in the 'actual' and 'expected' hashes have the same value.)

              if ei && previous_ei && (ei - previous_ei) > 1
                # If we've jumped from one operation in the 'expected' hash to
                # another operation later in 'expected' (due to the fact that the
                # 'expected' hash is in a different order than 'actual'), collect
                # any delete operations in between and add them to our operations
                # array as deletes before adding the noop. If we don't do this
                # now, then those deletes will disappear. (Again, we are mainly
                # iterating over 'actual', so this is the only way to catch all of
                # the keys in 'expected'.)
                (previous_ei + 1).upto(ei - 1) do |ei2|
                  ek = eks[ei2]
                  ev2 = expected[ek]
                  av2 = actual[ek]

                  next unless
                       (!actual.include?(ek) || ev2 != av2) &&
                       operations.none? do |operation|
                         %i[delete noop].include?(operation.name) &&
                         operation.key == ek
                       end

                  operations << Core::UnaryOperation.new(
                    name: :delete,
                    collection: expected,
                    key: ek,
                    value: ev2,
                    index: ei2
                  )
                end
              end

              operations << Core::UnaryOperation.new(
                name: :noop,
                collection: actual,
                key: ak,
                value: av,
                index: ai
              )
            else
              # (If we're here, it probably means that the key in 'actual' isn't
              # present in 'expected' or the values don't match.)

              if (operations.empty? || operations.last.name == :noop) &&
                 (ai.zero? || eks.include?(aks[ai - 1]))

                # If we go from a match in the last iteration to a missing or
                # extra key in this one, or we're at the first key in 'actual' and
                # it's missing or extra, look for deletes in the 'expected' hash
                # and add them to our list of operations before we add the
                # inserts. In most cases we will accomplish this by backtracking a
                # bit to the key in 'expected' that matched the key in 'actual' we
                # processed in the previous iteration (or just the first key in
                # 'expected' if this is the first key in 'actual'), and then
                # iterating from there through 'expected' until we reach the end
                # or we hit some other condition (see below).

                start_index =
                  if ai.positive?
                    eks.index(aks[ai - 1]) + 1
                  else
                    0
                  end

                start_index.upto(eks.size - 1) do |ei2|
                  ek = eks[ei2]
                  ev2 = expected[ek]
                  av2 = actual[ek]

                  if actual.include?(ek) && ev2 == av2
                    # If the key in 'expected' we've landed on happens to be a
                    # match in 'actual', then stop, because it's going to be
                    # handled in some future iteration of the 'actual' loop.
                    break
                  elsif aks[ai + 1..].include?(ek) # rubocop:disable Lint/DuplicateBranch -- for clarity
                    # While we backtracked a bit to iterate over 'expected', we
                    # now have to look ahead. If we will end up encountering a
                    # insert that matches this delete later, stop and go back to
                    # iterating over 'actual'. This is because the delete we would
                    # have added now will be added later when we encounter the
                    # associated insert, so we don't want to add it twice.
                    break
                  elsif operations.any? { |op| op.key == ek && op.name == :delete }
                    # We already removed this expected key in the outer loop,
                    # specifically from a value mismatch where the key appears
                    # in `actual` before it appears in `expected`. Don't remove
                    # it again.

                    # NOTE: the op.name == :delete is technically redundant,
                    # but hopefully clarifying.
                    # :noop is covered by the first branch in this if/else.
                    # :insert alone isn't possible here; that would imply `ek`
                    # was in `actual` but _not_ `expected`, yet we're looking at
                    # a key in `ek` right now.
                    next
                  else
                    operations << Core::UnaryOperation.new(
                      name: :delete,
                      collection: expected,
                      key: ek,
                      value: ev2,
                      index: ei2
                    )
                  end

                  next unless ek == ak && ev2 != av

                  # If we're pointing to the same key in 'expected' as in
                  # 'actual', but with different values, go ahead and add an
                  # insert now to accompany the delete added above. That way
                  # they appear together, which will be easier to read.
                  operations << Core::UnaryOperation.new(
                    name: :insert,
                    collection: actual,
                    key: ak,
                    value: av,
                    index: ai
                  )
                end
              end

              if expected.include?(ak) && ev != av &&
                 operations.none? do |op|
                   op.name == :delete && op.key == ak
                 end

                # If we're here, it means that we didn't encounter any delete
                # operations above for whatever reason and so we need to add a
                # delete to represent the fact that the value for this key has
                # changed.
                operations << Core::UnaryOperation.new(
                  name: :delete,
                  collection: expected,
                  key: ak,
                  value: expected[ak],
                  index: ei
                )
              end

              if operations.none? { |op| op.name == :insert && op.key == ak }
                # If we're here, it means that we didn't encounter any insert
                # operations above. Since we already handled delete, the only
                # alternative is that this key must not exist in 'expected', so
                # we need to add an insert.
                operations << Core::UnaryOperation.new(
                  name: :insert,
                  collection: actual,
                  key: ak,
                  value: av,
                  index: ai
                )
              end
            end

            previous_ei = ei
          end

          # The last thing to do is this: if there are keys in 'expected' that
          # aren't in 'actual', and they aren't associated with any inserts to
          # where they would have been added above, tack those deletes onto the
          # end of our operations array.
          (eks - aks - operations.map(&:key)).each do |ek|
            ei = eks.index(ek)
            ev = expected[ek]

            operations << Core::UnaryOperation.new(
              name: :delete,
              collection: expected,
              key: ek,
              value: ev,
              index: ei
            )
          end

          operations
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
