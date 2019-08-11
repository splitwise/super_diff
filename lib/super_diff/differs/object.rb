module SuperDiff
  module Differs
    class Object < Base
      def self.applies_to?(expected, actual)
        expected.is_a?(::Object) && actual.is_a?(::Object)
      end

      def self.call(
        expected,
        actual,
        indent_level:,
        index_in_collection:,
        **rest
      )
        super(
          expected,
          actual,
          indent_level: indent_level,
          index_in_collection: index_in_collection,
          **rest
        )
      end

      def self.inspection_lines_for(value)
        inspected_value = value.inspect
        match = inspected_value.match(/\A#<([^ ]+)(.*)>\Z/)

        if match
          [
            "#<#{match.captures[0]} {",
            *match.captures[1].split(" ").map { |line| "  " + line },
            "}>",
          ]
        else
          [inspected_value]
        end
      end

      def call
        lines.join("\n")
      end

      private

      attr_reader :expected, :actual, :indent_level, :index_in_collection

      def lines
        [
          styled_lines_for("-", :deleted, expected),
          styled_lines_for("+", :inserted, actual),
        ]
      end

      def styled_lines_for(icon, style_name, value)
        unstyled_lines_for(icon, value).map do |line|
          Helpers.style(style_name, line)
        end
      end

      def unstyled_lines_for(icon, value)
        lines = self.class.inspection_lines_for(value).
          map { |inspection_line| "#{icon} #{indentation}#{inspection_line}" }

        lines
      end
    end
  end
end
