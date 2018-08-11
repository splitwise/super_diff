module SuperDiff
  module Csi
    class EightBitColor
      VALID_COMPONENT_RANGE = 0..6
      VALID_CODE_RANGE = 0..255
      VALID_CODES_BY_NAME = {
        black: 0,
        red: 1,
        green: 2,
        yellow: 3,
        blue: 4,
        magenta: 5,
        cyan: 6,
        white: 7,
        bright_black: 8,
        bright_red: 9,
        bright_green: 10,
        bright_yellow: 11,
        bright_blue: 12,
        bright_magenta: 13,
        bright_cyan: 14,
        bright_white: 15
      }
      STARTING_INDICES = {
        standard: 0,
        high_intensity: 8,
        grayscale: 232
      }
      VALID_PAIR_TYPES = STARTING_INDICES.keys
      VALID_PAIR_INDEX_RANGES = {
        standard: 0..7,
        high_intensity: 0..7,
        grayscale: 0..23
      }
      LEADING_CODES_BY_LAYER = { fg: 38, bg: 48 }
      SERIAL_CODE = 5

      def initialize(value)
        case value
        when Hash
          @code = interpret_triplet!(value)
        when Symbol
          @code = interpret_color_name!(value)
        when Array
          @code = interpret_pair!(value)
        else
          @code = interpret_code!(value)
        end
      end

      def sequence_for(layer)
        leading_code = LEADING_CODES_BY_LAYER.fetch(layer)
        "\e[#{leading_code};#{SERIAL_CODE};#{code}m"
      end

      private

      attr_reader :code

      def interpret_triplet!(spec)
        if !spec.include?(:r) || !spec.include?(:g) || !spec.include?(:b)
          raise ArgumentError.new(
            "#{spec.inspect} is not a valid color specification. " +
            "Please provide a hash with :r, :g, and :b keys."
          )
        end

        if spec.values.any? { |component| !VALID_COMPONENT_RANGE.cover?(component) }
          raise ArgumentError.new(
            "(#{spec[:r]},#{spec[:g]},#{spec[:b]}) is not a valid color " +
            "specification. All components must be between " +
            "#{VALID_COMPONENT_RANGE.begin} and #{VALID_COMPONENT_RANGE.end}."
          )
        end

        16 + 36 * spec[:r] + 6 * spec[:g] + spec[:b]
      end

      def interpret_color_name!(name)
        if !VALID_CODES_BY_NAME.include?(name)
          message =
            "#{name.inspect} is not a valid color name.\n" +
            "Valid names are:\n"

          VALID_CODES_BY_NAME.keys.each do |valid_name|
            message << "- #{valid_name}\n"
          end

          raise ArgumentError.new(message)
        end

        VALID_CODES_BY_NAME[name]
      end

      def interpret_pair!(pair)
        type, index = pair

        if !VALID_PAIR_TYPES.include?(type)
          raise ArgumentError.new(
            "Given pair did not have a valid type. " +
            "Type must be one of: #{VALID_PAIR_TYPES}"
          )
        end

        valid_range = VALID_PAIR_INDEX_RANGES[type]

        if !valid_range.cover?(index)
          raise ArgumentError.new(
            "Given pair did not have a valid index. " +
            "For #{type}, index must be between #{valid_range.begin} and " +
            "#{valid_range.end}."
          )
        end

        STARTING_INDICES[type] + index
      end

      def interpret_code!(code)
        if !VALID_CODE_RANGE.cover?(code)
          raise ArgumentError.new(
            "#{code.inspect} is not a valid color code " +
            "(must be between 0 and 255)."
          )
        end

        code
      end
    end
  end
end
