# frozen_string_literal: true

module SuperDiff
  module Core
    module DiffFormatters
      # TODO: Remove
      class MultilineString < Base
        def self.applies_to?(operation_tree)
          operation_tree.is_a?(OperationTrees::MultilineString)
        end

        def call
          lines.join("\n")
        end

        private

        def lines
          operation_tree.reduce([]) do |array, operation|
            case operation.name
            when :change
              array << Helpers.style(:expected, "- #{operation.left_value}")
              array << Helpers.style(:actual, "+ #{operation.right_value}")
            when :delete
              array << Helpers.style(:expected, "- #{operation.value}")
            when :insert
              array << Helpers.style(:actual, "+ #{operation.value}")
            else
              array << Helpers.style(:plain, "  #{operation.value}")
            end
          end
        end
      end
    end
  end
end
