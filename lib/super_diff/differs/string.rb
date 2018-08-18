module SuperDiff
  module Differs
    class String < Base
      def self.applies_to?(value)
        value.is_a?(::String)
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

      def call
        lines.join("\n")
      end

      private

      def lines
        [
          styled_lines_for("-", :deleted, expected),
          styled_lines_for("+", :inserted, actual)
        ]
      end

      def styled_lines_for(icon, style_name, collection)
        Helpers.style(style_name, unstyled_line_for(icon, collection))
      end

      def unstyled_line_for(icon, collection)
        value = collection[op.index]
        line = "#{icon} #{indentation}#{value.inspect}"

        if index_in_collection < collection.length - 1
          line << ","
        end

        line
      end
    end
  end
end
