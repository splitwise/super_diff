require_relative "../csi"

module SuperDiff
  module EqualityMatchers
    class Base
      ICONS = { deleted: "-", inserted: "+" }
      STYLES = { inserted: :inserted, deleted: :deleted, equal: :normal }
      COLORS = { normal: :plain, inserted: :green, deleted: :red }

      def self.call(expected, actual)
        new(expected, actual).call
      end

      def initialize(expected, actual)
        @expected = expected
        @actual = actual
      end

      def call
        if expected == actual
          ""
        else
          fail
        end
      end

      protected

      attr_reader :expected, :actual

      def fail
        raise NotImplementedError
      end

      def style(style_name, text)
        Csi::ColorHelper.public_send(COLORS.fetch(style_name), text)
      end

      def plural_type_for(value)
        case value
        when Numeric then "numbers"
        when String then "strings"
        when Symbol then "symbols"
        else "objects"
        end
      end

      def inspect(value)
        case value
        when ::Hash
          value.inspect.
            gsub(/([^,]+)=>([^,]+)/, '\1 => \2').
            gsub(/:(\w+) => /, '\1: ').
            gsub(/\{([^{}]+)\}/, '{ \1 }')
        when String
          newline = "⏎"
          value.gsub(/\r\n/, newline).gsub(/\n/, newline).inspect
        else
          inspected_value = value.inspect
          match = inspected_value.match(/\A#<([^ ]+)(.*)>\Z/)

          if match
            [
              "#<#{match.captures[0]} {",
              *match.captures[1].split(" ").map { |line| "  " + line },
              "}>"
            ].join("\n")
          else
            inspected_value
          end
        end
      end
    end
  end
end
