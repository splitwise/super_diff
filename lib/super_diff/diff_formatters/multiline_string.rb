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
            array << Helpers.style(:alpha, "- #{operation.left_value}")
            array << Helpers.style(:beta, "+ #{operation.right_value}")
          when :delete
            array << Helpers.style(:alpha, "- #{operation.value}")
          when :insert
            array << Helpers.style(:beta, "+ #{operation.value}")
          else
            array << Helpers.style(:plain, "  #{operation.value}")
          end
        end
      end
    end
  end
end
