require_relative "../helpers"
require_relative "collection"

module SuperDiff
  module DiffFormatters
    class Hash
      def self.call(operations, indent:)
        Collection.call(
          open_token: "{",
          close_token: "}",
          operations: operations,
          indent: indent
        ) do |op|
          key = op.key
          inspected_value = Helpers.inspect_object(op.collection[op.key])

          if key.is_a?(Symbol)
            "#{key}: #{inspected_value}"
          else
            "#{key.inspect} => #{inspected_value}"
          end
        end
      end
    end
  end
end
