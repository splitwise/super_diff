module SuperDiff
  module DiffFormatters
    class MultiLineString < Base
      def self.applies_to?(operations)
        operations.is_a?(OperationSequences::MultiLineString)
      end

      def call
        lines.join("\n")
      end

      private

      def lines
        operations.inject([]) do |array, op|
          case op.name
          when :change
            array << Helpers.style(:deleted, "- #{op.left_value}")
            array << Helpers.style(:inserted, "+ #{op.right_value}")
          when :delete
            array << Helpers.style(:deleted, "- #{op.value}")
          when :insert
            array << Helpers.style(:inserted, "+ #{op.value}")
          else
            array << Helpers.style(:normal, "  #{op.value}")
          end
        end
      end
    end
  end
end
