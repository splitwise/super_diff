# frozen_string_literal: true

module SuperDiff
  module Capybara
    module Differs
      # Nodes are compared as opaque values, since their instance variables
      # lead to the session, the driver and the browser connection.
      class Node < Core::AbstractDiffer
        def self.applies_to?(expected, actual)
          SuperDiff::Capybara.applies_to?(expected, actual)
        end

        def call
          Core::TieredLinesFormatter.call(
            [line(:delete, expected), line(:insert, actual)]
          )
        end

        private

        def line(type, node)
          Core::Line.new(
            type: type,
            indentation_level: indent_level,
            value: SuperDiff.inspect_object(node, as_lines: false)
          )
        end
      end
    end
  end
end
