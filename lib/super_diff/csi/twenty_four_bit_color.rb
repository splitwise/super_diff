module SuperDiff
  module Csi
    class TwentyFourBitColor < Color
      VALID_COMPONENT_RANGE = (0..255).freeze
      LEADING_CODES_BY_LAYER = { foreground: 38, background: 48 }.freeze
      LAYERS_BY_LEADING_CODE = LEADING_CODES_BY_LAYER.invert.freeze
      SERIAL_CODE = 2
      OPENING_REGEX = /\e\[(\d+);#{SERIAL_CODE};(\d+);(\d+);(\d+)m/.freeze

      def self.opening_regex
        OPENING_REGEX
      end

      def initialize(value = nil, layer: nil, red: nil, green: nil, blue: nil)
        if value
          pair = interpret_sequence!(value)
          @triplet = pair.fetch(:triplet)
          @layer = pair.fetch(:layer)
        else
          @triplet = interpret_triplet!(red: red, green: green, blue: blue)
          @layer = interpret_layer!(layer)
        end
      end

      def to_s
        [
          "\e[#{leading_code}",
          SERIAL_CODE,
          triplet.red,
          triplet.blue,
          triplet.green
        ].join(";") + "m"
      end

      def to_foreground
        self.class.new(
          red: triplet.red,
          green: triplet.green,
          blue: triplet.blue,
          layer: :foreground
        )
      end

      private

      attr_reader :triplet

      def leading_code
        LEADING_CODES_BY_LAYER.fetch(layer)
      end

      def interpret_sequence!(sequence)
        match = sequence.match(OPENING_REGEX)

        if match
          {
            layer: interpret_layer!(match[1]),
            triplet:
              interpret_triplet!(
                red: match[2].to_i,
                green: match[3].to_i,
                blue: match[4].to_i
              )
          }
        end
      end

      def interpret_triplet!(red:, green:, blue:)
        if invalid_triplet?(red, green, blue)
          raise ArgumentError.new(
                  "(#{red},#{green},#{blue}) is not a valid color " +
                    "specification. All components must be between " +
                    "#{VALID_COMPONENT_RANGE.begin} and #{VALID_COMPONENT_RANGE.end}."
                )
        end

        Triplet.new(red: red, green: green, blue: blue)
      end

      def invalid_triplet?(*values)
        values.none? { |component| VALID_COMPONENT_RANGE.cover?(component) }
      end

      def interpret_layer!(value)
        if value.to_s.to_i > 0
          LAYERS_BY_LEADING_CODE.fetch(value.to_s.to_i)
        else
          super
        end
      end

      class Triplet
        attr_reader :red, :green, :blue

        def initialize(red:, green:, blue:)
          @red = red
          @green = green
          @blue = blue
        end
      end
    end
  end
end
