module SuperDiff
  module Csi
    class FourBitColor < Color
      VALID_TYPES = [:foreground, :background].freeze
      VALID_CODES_BY_NAME = {
        black: { foreground: 30, background: 40 },
        red: { foreground: 31, background: 41 },
        green: { foreground: 32, background: 42 },
        yellow: { foreground: 33, background: 43 },
        blue: { foreground: 34, background: 44 },
        magenta: { foreground: 35, background: 45 },
        cyan: { foreground: 36, background: 46 },
        white: { foreground: 37, background: 47 },
        bright_black: { foreground: 90, background: 100 },
        bright_red: { foreground: 91, background: 101 },
        bright_green: { foreground: 92, background: 102 },
        bright_yellow: { foreground: 93, background: 103 },
        bright_blue: { foreground: 94, background: 104 },
        bright_magenta: { foreground: 95, background: 105 },
        bright_cyan: { foreground: 96, background: 106 },
        bright_white: { foreground: 97, background: 107 },
      }.freeze
      COLORS_BY_CODE = VALID_CODES_BY_NAME.reduce({}) do |hash, (name, value)|
        hash.merge(
          value[:foreground] => { name: name, layer: :foreground },
          value[:background] => { name: name, layer: :background },
        )
      end
      VALID_NAMES = VALID_CODES_BY_NAME.keys
      VALID_CODE_RANGES = [30..37, 40..47, 90..97, 100..107].freeze
      OPENING_REGEX = /\e\[(\d+)m/.freeze

      def self.exists?(name)
        VALID_CODES_BY_NAME.has_key?(name)
      end

      def self.opening_regex
        OPENING_REGEX
      end

      def initialize(value, layer: nil)
        if value.is_a?(Symbol)
          @name = interpret_name!(value)
          @layer = interpret_layer!(layer)
        else
          pair =
            if value.start_with?("\e[")
              interpret_sequence!(value)
            else
              interpret_code!(value)
            end

          @name = pair.fetch(:name)
          @layer = pair.fetch(:layer)
        end
      end

      def to_s
        code = VALID_CODES_BY_NAME.fetch(name).fetch(layer)
        "\e[#{code}m"
      end

      def to_foreground
        self.class.new(name, layer: :foreground)
      end

      private

      attr_reader :name

      def interpret_name!(name)
        if !VALID_NAMES.include?(name)
          message =
            "#{name.inspect} is not a valid color name.\n" +
            "Valid names are:\n"

          VALID_NAMES.each do |valid_name|
            message << "- #{valid_name}"
          end

          raise ArgumentError.new(message)
        end

        name
      end

      def interpret_sequence!(sequence)
        match = sequence.match(OPENING_REGEX)

        if match
          interpret_code!(match[1].to_i)
        end
      end

      def interpret_code!(code)
        if VALID_CODE_RANGES.none? { |range| range.cover?(code) }
          message =
            "#{code.inspect} is not a valid color code.\n" +
            "Valid codes are:\n"

          VALID_CODE_RANGES.each do |range|
            message << "- #{range.begin} through #{range.end}\n"
          end

          raise ArgumentError.new(message)
        end

        COLORS_BY_CODE.fetch(code)
      end
    end
  end
end
