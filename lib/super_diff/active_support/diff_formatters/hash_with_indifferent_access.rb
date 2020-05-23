module SuperDiff
  module ActiveSupport
    module DiffFormatters
      class HashWithIndifferentAccess < SuperDiff::DiffFormatters::Base
        def self.applies_to?(operation_tree)
          operation_tree.is_a?(OperationTrees::HashWithIndifferentAccess)
        end

        def call
          SuperDiff::DiffFormatters::Collection.call(
            open_token: "#<HashWithIndifferentAccess {",
            close_token: "}>",
            collection_prefix: collection_prefix,
            build_item_prefix: -> (operation) {
              key =
                if operation.respond_to?(:left_key)
                  operation.left_key
                else
                  operation.key
                end

              if key.is_a?(Symbol)
                "#{key}: "
              else
                "#{key.inspect} => "
              end
            },
            operation_tree: operation_tree,
            indent_level: indent_level,
            add_comma: add_comma?,
          )
        end
      end
    end
  end
end
