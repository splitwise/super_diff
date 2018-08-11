module SuperDiff
  module Csi
    class FourBitSequence
      def initialize(fg: nil, bg: nil)
        @fg = fg
        @bg = bg
      end

      def to_s
        [sequence_for(fg), sequence_for(bg)].compact.join
      end

      private

      attr_reader :fg, :bg

      def sequence_for(color)
        if color
          "\e[#{color.code}m"
        end
      end
    end
  end
end
