require_relative "../helpers"

module SuperDiff
  module DiffFormatters
    class MultiLineString
      def self.call(operations, indent:)
        new(operations, indent: indent).call
      end

      def initialize(operations, indent:)
        @operations = operations
        @indent = indent
      end

      def call
        lines.join("\n")
      end

      private

      attr_reader :operations, :indent

      def lines
        operations.map do |op|
          text = op.collection[op.index]

          case op.name
          when :noop
            Helpers.style(:normal, "  #{text}")
          when :insert
            Helpers.style(:inserted, "+ #{text}")
          when :delete
            Helpers.style(:deleted, "- #{text}")
          end
        end
      end
    end
  end
end
