require_relative "../helpers"

module SuperDiff
  module DiffFormatters
    class Array
      def self.call(operations, indent:)
        Collection.call(
          open_token: "[",
          close_token: "]",
          operations: operations,
          indent: indent
        ) do |op|
          Helpers.inspect_object(op.collection[op.index])
        end
      end
    end
  end
end
