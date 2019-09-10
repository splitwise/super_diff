module SuperDiff
  module DiffFormatters
    class MultilineString < Base
      def self.applies_to?(operations)
        operations.is_a?(OperationSequences::MultilineString)
      end

      def call
        lines.join("\n")
      end

      private

      def lines
        operations.reduce([]) do |array, operation|
          case operation.name
          when :change
            array << Helpers.style(:deleted, "- #{operation.left_value}")
            array << Helpers.style(:inserted, "+ #{operation.right_value}")
          when :delete
            array << Helpers.style(:deleted, "- #{operation.value}")
          when :insert
            array << Helpers.style(:inserted, "+ #{operation.value}")
          else
            array << Helpers.style(:normal, "  #{operation.value}")
          end
        end
      end
    end
  end
end
