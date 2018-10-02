module SuperDiff
  module Csi
    class TwentyFourBitColor
      VALID_COMPONENT_RANGE = 0..255
      LEADING_CODES_BY_LAYER = { fg: 38, bg: 48 }.freeze
      SERIAL_CODE = 2

      def initialize(value)
        @code = interpret_triplet!(value)
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
            "Please provide a hash with :r, :g, and :b keys.",
          )
        end

        if spec.values.any? { |component| !VALID_COMPONENT_RANGE.cover?(component) }
          raise ArgumentError.new(
            "(#{spec[:r]},#{spec[:g]},#{spec[:b]}) is not a valid color " +
            "specification. All components must be between " +
            "#{VALID_COMPONENT_RANGE.begin} and #{VALID_COMPONENT_RANGE.end}.",
          )
        end

        "#{spec[:r]};#{spec[:g]};#{spec[:b]}"
      end
    end
  end
end
