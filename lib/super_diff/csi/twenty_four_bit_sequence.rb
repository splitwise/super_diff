module SuperDiff
  module Csi
    class TwentyFourBitSequence
      LEADING_CODES = { fg: 38, bg: 48 }.freeze
      SERIAL_CODE = 2

      def initialize(fg: nil, bg: nil)
        @fg = fg
        @bg = bg
      end

      def to_s
        [sequence_for(:fg, fg), sequence_for(:bg, bg)].compact.join
      end

      private

      attr_reader :fg, :bg

      def sequence_for(type, color)
        if color
          "\e[#{LEADING_CODES.fetch(type)};#{SERIAL_CODE};#{color.code}m"
        end
      end
    end
  end
end
