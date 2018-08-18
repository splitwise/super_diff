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

    def self.inspect_object(value_to_inspect, single_line: true)
      case value_to_inspect
      when ::Hash
        # value.inspect.
          # gsub(/([^,]+)=>([^,]+)/, '\1 => \2').
          # gsub(/:(\w+) => /, '\1: ').
          # gsub(/\{([^{}]+)\}/, '{ \1 }')

        hash = value_to_inspect

        contents = hash.map do |key, value|
          if key.is_a?(Symbol)
            "#{key}: #{inspect_object(value)}"
          else
            "#{inspect_object(key)} => #{inspect_object(value)}"
          end
        end

        ["{", contents.join(", "), "}"].join(" ")
      when String
        string = value_to_inspect
        newline = "⏎"
        string.gsub(/\r\n/, newline).gsub(/\n/, newline).inspect
      when ::Array
        array = value_to_inspect
        "[" + array.map { |element| inspect_object(element) }.join(", ") + "]"
      else
        object = value_to_inspect

        if object.respond_to?(:attributes_for_super_diff)
          attributes = object.attributes_for_super_diff
          inspected_attributes =
            attributes.map.with_index do |(key, value), index|
              "#{key}: #{value.inspect}".tap do |line|
                if index < attributes.size - 1
                  line << ","
                end
              end
            end

          if single_line
            "#<#{object.class} #{inspected_attributes.join(" ")}>"
          else
            ValueInspection.new(
              beginning: "#<#{object.class} {",
              middle: inspected_attributes,
              end: "}>"
            )
          end
        else
          object.inspect
          # inspected_value = value.inspect
          # match = inspected_value.match(/\A#<([^ ]+)(.*)>\Z/)

          # if match
            # [
              # "#<#{match.captures[0]} {",
              # *match.captures[1].split(" ").map { |line| "  " + line },
              # "}>"
            # ].join("\n")
          # else
            # inspected_value
          # end
        end
      end
    end

  end
end
