module SuperDiff
  module Csi
    class EightBitColor < Color
      VALID_COMPONENT_RANGE = (0..6).freeze
      VALID_CODE_RANGE = (0..255).freeze
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
      }.freeze
      STARTING_INDICES = {
        standard: 0,
        high_intensity: 8,
        grayscale: 232
      }.freeze
      VALID_PAIR_TYPES = STARTING_INDICES.keys
      VALID_PAIR_INDEX_RANGES = {
        standard: 0..7,
        high_intensity: 0..7,
        grayscale: 0..23
      }.freeze
      LEADING_CODES_BY_LAYER = { foreground: 38, background: 48 }.freeze
      LAYERS_BY_LEADING_CODE = LEADING_CODES_BY_LAYER.invert.freeze
      SERIAL_CODE = 5
      OPENING_REGEX = /\e\[(\d+);#{SERIAL_CODE};(\d+)m/.freeze

      def self.opening_regex
        OPENING_REGEX
      end

      def initialize(
        value = nil,
        layer: nil,
        red: nil,
        green: nil,
        blue: nil,
        type: nil,
        index: nil
      )
        if value
          case value
          when Symbol
            @code = interpret_color_name!(value)
            @layer = interpret_layer!(layer)
          when Array
            @code = interpret_pair!(type: type, index: index)
            @layer = interpret_layer!(layer)
          else
            if value.is_a?(String) && value.start_with?("\e[")
              pair = interpret_sequence!(value)
              @code = pair.fetch(:code)
              @layer = pair.fetch(:layer)
            else
              @code = interpret_code!(value)
              @layer = interpret_layer!(layer)
            end
          end
        else
          @code = interpret_triplet!(red: red, green: green, blue: blue)
          @layer = interpret_layer!(layer)
        end
      end

      def to_s
        "\e[#{leading_code};#{SERIAL_CODE};#{code}m"
      end

      def to_foreground
        self.class.new(code, layer: :foreground)
      end

      private

      attr_reader :code

      def leading_code
        LEADING_CODES_BY_LAYER.fetch(layer)
      end

      def interpret_triplet!(red:, green:, blue:)
        if invalid_triplet?(red, green, blue)
          raise ArgumentError.new(
                  "(#{red},#{green},#{blue}) is not a valid color " +
                    "specification. All components must be between " +
                    "#{VALID_COMPONENT_RANGE.begin} and #{VALID_COMPONENT_RANGE.end}."
                )
        end

        16 + 36 * red + 6 * green + blue
      end

      def invalid_triplet?(*values)
        values.none? { |component| VALID_COMPONENT_RANGE.cover?(component) }
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

      def interpret_pair!(type:, index:)
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

      def interpret_sequence!(sequence)
        match = sequence.match(OPENING_REGEX)

        if match
          {
            layer: interpret_layer!(match[1]),
            code: interpret_code!(match[2].to_i)
          }
        end
      end

      def interpret_layer!(value)
        if value.to_s.to_i > 0
          LAYERS_BY_LEADING_CODE.fetch(value.to_s.to_i)
        else
          super
        end
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
