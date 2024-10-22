# frozen_string_literal: true

module SuperDiff
  module Basic
    module OperationTreeFlatteners
      class DefaultObject < Collection
        protected

        def open_token
          "#<#{operation_tree.underlying_object.class.name}:" \
            "#{Core::Helpers.object_address_for(operation_tree.underlying_object)} {"
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

          "@#{key}="
        end
      end
    end
  end
end
