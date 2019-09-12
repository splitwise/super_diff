module SuperDiff
  module Rails
    module DiffFormatters
      class HashWithIndifferentAccess < SuperDiff::DiffFormatters::Base
        def self.applies_to?(operations)
          operations.is_a?(OperationSequences::HashWithIndifferentAccess)
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
            operations: operations,
            indent_level: indent_level,
            add_comma: add_comma?,
          )
        end
      end
    end
  end
end
