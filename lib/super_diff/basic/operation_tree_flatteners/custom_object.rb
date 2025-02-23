# frozen_string_literal: true

module SuperDiff
  module Basic
    module OperationTreeFlatteners
      class CustomObject < Collection
        protected

        def open_token
          format('#<%<class>s {', class: operation_tree.underlying_object.class)
        end

        def close_token
          '}>'
        end

        def item_prefix_for(operation)
          key =
            # NOTE: We could have used the right_key here too, they're both the
            # same keys
            if operation.respond_to?(:left_key)
              operation.left_key
            else
              operation.key
            end

          "#{key}: "
        end
      end
    end
  end
end
