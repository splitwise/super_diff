module SuperDiff
  module Helpers
    COLORS = { normal: :plain, inserted: :green, deleted: :red }.freeze

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
        inspect_hash(value_to_inspect, single_line: single_line)
      when String
        inspect_string(value_to_inspect)
      when ::Array
        inspect_array(value_to_inspect)
      else
        inspect_unclassified_object(value_to_inspect, single_line: single_line)
      end
    end

    def self.values_equal?(expected, actual)
      expected == actual
    end

    def self.inspect_hash(hash, single_line: true)
      contents = hash.map do |key, value|
        if key.is_a?(Symbol)
          "#{key}: #{inspect_object(value)}"
        else
          "#{inspect_object(key)} => #{inspect_object(value)}"
        end
      end

      if single_line
        ["{", contents.join(", "), "}"].join(" ")
      else
        ValueInspection.new(
          beginning: "{",
          middle: contents.map.with_index do |line, index|
            if index < contents.size - 1
              line + ","
            else
              line
            end
          end,
          end: "}",
        )
      end
    end
    private_class_method :inspect_hash

    def self.inspect_string(string)
      newline = "⏎"
      string.gsub(/\r\n/, newline).gsub(/\n/, newline).inspect
    end
    private_class_method :inspect_string

    def self.inspect_array(array)
      "[" + array.map { |element| inspect_object(element) }.join(", ") + "]"
    end
    private_class_method :inspect_array

    def self.inspect_unclassified_object(object, single_line: true)
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
            end: "}>",
          )
        end
      else
        object.inspect
      end
    end
    private_class_method :inspect_unclassified_object
  end
end
