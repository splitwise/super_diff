module SuperDiff
  module Csi
    class FourBitColor
      VALID_TYPES = [:fg, :bg]
      VALID_CODES_BY_NAME = {
        black: { fg: 30, bg: 40 },
        red: { fg: 31, bg: 41 },
        green: { fg: 32, bg: 42 },
        yellow: { fg: 33, bg: 43 },
        blue: { fg: 34, bg: 44 },
        magenta: { fg: 35, bg: 45 },
        cyan: { fg: 36, bg: 46 },
        white: { fg: 37, bg: 47 },
        bright_black: { fg: 90, bg: 100 },
        bright_red: { fg: 91, bg: 101 },
        bright_green: { fg: 92, bg: 102 },
        bright_yellow: { fg: 93, bg: 103 },
        bright_blue: { fg: 94, bg: 104 },
        bright_magenta: { fg: 95, bg: 105 },
        bright_cyan: { fg: 96, bg: 106 },
        bright_white: { fg: 97, bg: 107 }
      }
      NAMES_BY_CODE = VALID_CODES_BY_NAME.inject({}) do |hash, (key, value)|
        hash.merge(value[:fg] => key, value[:bg] => key)
      end
      VALID_NAMES = VALID_CODES_BY_NAME.keys
      VALID_CODE_RANGES = [30..37, 40..47, 90..97, 100..107]

      def initialize(value)
        if value.is_a?(Symbol)
          @name = interpret_name!(value)
        else
          @name = interpret_code!(value)
        end
      end

      def sequence_for(layer)
        code = VALID_CODES_BY_NAME.fetch(name).fetch(layer)
        "\e[#{code}m"
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

      def interpret_code!(code)
        if !VALID_CODE_RANGES.any? { |range| !range.cover?(code) }
          message =
            "#{code.inspect} is not a valid color code.\n" +
            "Valid codes are:\n"

          VALID_CODE_RANGES.each do |range|
            message << "- #{range.begin} through #{range.end}\n"
          end

          raise ArgumentError.new(message)
        end

        NAMES_BY_CODE.fetch(code)
      end
    end
  end
end
