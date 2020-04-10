module SuperDiff
  module OperationalSequencers
    class Hash < Base
      def self.applies_to?(expected, actual)
        expected.is_a?(::Hash) && actual.is_a?(::Hash)
      end

      protected

      def unary_operations
        all_keys.reduce([]) do |operations, key|
          possibly_add_noop_to(operations, key)
          possibly_add_delete_to(operations, key)
          possibly_add_insert_to(operations, key)
          operations
        end
      end

      def build_operation_sequence
        OperationSequences::Hash.new([])
      end

      private

      def all_keys
        actual.keys | expected.keys
      end

      def possibly_add_noop_to(operations, key)
        if should_add_noop_operation?(key)
          operations << Operations::UnaryOperation.new(
            name: :noop,
            collection: actual,
            key: key,
            index: all_keys.index(key),
            index_in_collection: actual.keys.index(key),
            value: actual[key],
          )
        end
      end

      def should_add_noop_operation?(key)
        expected.include?(key) &&
          actual.include?(key) &&
          expected[key] == actual[key]
      end

      def possibly_add_delete_to(operations, key)
        if should_add_delete_operation?(key)
          operations << Operations::UnaryOperation.new(
            name: :delete,
            collection: expected,
            key: key,
            index: all_keys.index(key),
            index_in_collection: expected.keys.index(key),
            value: expected[key],
          )
        end
      end

      def should_add_delete_operation?(key)
        expected.include?(key) &&
          (!actual.include?(key) || expected[key] != actual[key])
      end

      def possibly_add_insert_to(operations, key)
        if should_add_insert_operation?(key)
          operations << Operations::UnaryOperation.new(
            name: :insert,
            collection: actual,
            key: key,
            index: all_keys.index(key),
            index_in_collection: actual.keys.index(key),
            value: actual[key],
          )
        end
      end

      def should_add_insert_operation?(key)
        !expected.include?(key) ||
          (actual.include?(key) && expected[key] != actual[key])
      end
    end
  end
end
