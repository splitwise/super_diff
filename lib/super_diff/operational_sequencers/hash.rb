module SuperDiff
  module OperationalSequencers
    class Hash < Base
      def self.applies_to?(value)
        value.is_a?(::Hash)
      end

      protected

      def unary_operations
        all_keys.inject([]) do |operations, key|
          if (
            expected.include?(key) &&
            actual.include?(key) &&
            expected[key] == actual[key]
          )
            operations << Operations::UnaryOperation.new(
              name: :noop,
              collection: actual,
              key: key,
              index: all_keys.index(key),
              value: actual[key]
            )
          end

          if (
            expected.include?(key) &&
            (!actual.include?(key) || expected[key] != actual[key])
          )
            operations << Operations::UnaryOperation.new(
              name: :delete,
              collection: expected,
              key: key,
              index: all_keys.index(key),
              value: expected[key]
            )
          end

          if (
            !expected.include?(key) ||
            (actual.include?(key) && expected[key] != actual[key])
          )
            operations << Operations::UnaryOperation.new(
              name: :insert,
              collection: actual,
              key: key,
              index: all_keys.index(key),
              value: actual[key]
            )
          end

          operations
        end
      end

      def operation_sequence_class
        OperationSequences::Hash
      end

      private

      def all_keys
        (expected.keys | actual.keys)
      end
    end
  end
end
