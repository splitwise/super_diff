module SuperDiff
  module OperationTreeFlatteners
    class Hash < Collection
      protected

      def open_token
        "{"
      end

      def close_token
        "}"
      end

      def item_prefix_for(operation)
        key = key_for(operation)

        if format_keys_as_kwargs?
          "#{key}: "
        else
          "#{key.inspect} => "
        end
      end

      private

      def format_keys_as_kwargs?
        operation_tree.all? { |operation| key_for(operation).is_a?(Symbol) }
      end

      def key_for(operation)
        # Note: We could have used the right_key here too, they're both the
        # same keys
        if operation.respond_to?(:left_key)
          operation.left_key
        else
          operation.key
        end
      end
    end
  end
end
