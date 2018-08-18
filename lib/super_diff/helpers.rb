require_relative "csi"

module SuperDiff
  module Helpers
    COLORS = { normal: :plain, inserted: :green, deleted: :red }

    def self.style(style_name, text)
      Csi::ColorHelper.public_send(COLORS.fetch(style_name), text)
    end

    def self.plural_type_for(value)
      case value
      when Numeric then "numbers"
      when String then "strings"
      when Symbol then "symbols"
      else "objects"
      end
    end

    def self.inspect_object(value)
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
