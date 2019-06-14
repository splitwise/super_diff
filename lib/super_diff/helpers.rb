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

    def self.inspect_object(value_to_inspect, single_line: true, level: 0)
      case value_to_inspect
      when ::Array
        inspect_array(value_to_inspect, single_line: single_line, level: level)
      when ::Hash
        inspect_hash(value_to_inspect, single_line: single_line, level: level)
      when String
        inspect_string(value_to_inspect)
      else
        inspect_unclassified_object(value_to_inspect, single_line: single_line)
      end
    end

    # TODO: Why don't we build a tree every time and let the inspection take
    # care of how to convert that tree into a string?
    def self.inspect_array(array, single_line: true, level: 0)
      pairs = array.map do |value|
        inspected_value = inspect_object(
          value,
          single_line: single_line,
          level: level + 1,
        )

        Pair.new(value: inspected_value)
      end

      if single_line
        ["[", pairs.map(&:to_s).join(", "), "]"].join
      else
        Inspection::BuildTree.call(
          opening: "[",
          middle: pairs,
          closing: "]",
          level: level,
        )
      end
    end
    private_class_method :inspect_array

    # TODO: Why don't we build a tree every time and let the inspection take
    # care of how to convert that tree into a string?
    def self.inspect_hash(hash, single_line: true, level: 0)
      pairs = hash.map do |key, value|
        inspected_key =
          if key.is_a?(Symbol)
            key
          else
            inspect_object(key, single_line: true)
          end

        inspected_value = inspect_object(
          value,
          single_line: single_line,
          level: level + 1,
        )

        Pair.new(key: inspected_key, value: inspected_value)
      end

      if single_line
        "{ " + pairs.map(&:to_s).join(", ") + " }"
      else
        Inspection::BuildTree.call(
          opening: "{",
          middle: pairs,
          closing: "}",
          level: level,
        )
      end
    end
    private_class_method :inspect_hash

    def self.inspect_string(string)
      newline = "⏎"
      string.gsub(/\r\n/, newline).gsub(/\n/, newline).inspect
    end
    private_class_method :inspect_string

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

    def self.values_equal?(expected, actual)
      SuperDiff.values_equal.call(expected, actual)
    end

    class Pair
      attr_reader :value

      def initialize(value:, **rest)
        @value = value
        @rest = rest
      end

      def key
        rest.fetch(:key)
      end

      def has_key?
        rest.include?(:key)
      end

      def as_prefix
        if has_key?
          if key.is_a?(Symbol)
            "#{key}: "
          else
            "#{key} => "
          end
        end
      end

      def to_s
        (as_prefix || "") + value
      end

      def pretty_print(pp)
        attribute_names =
          if has_key?
            [:key, :value]
          else
            [:value]
          end

        pp.object_address_group(self) do
          pp.seplist(attribute_names, proc { pp.text "," }) do |name|
            value = public_send(name)
            pp.breakable " "
            pp.group(1) do
              pp.text name.to_s
              pp.text ":"
              pp.breakable
              pp.pp value
            end
          end
        end
      end

      private

      attr_reader :rest
    end
  end
end
