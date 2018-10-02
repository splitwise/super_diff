module SuperDiff
  module Csi
    module Sequence
      def self.for(color)
        case color
        when :reset
          Csi::ResetSequence.new
        when FourBitColor
          Csi::FourBitSequence.new(color)
        when EightBitColor
          Csi::EightBitSequence.new(color)
        when TwentyFourBitColor
          Csi::TwentyFourBitSequence.new(color)
        else
          raise ArgumentError.new(
            "Don't know how to interpret color: #{color.inspect}",
          )
        end
      end
    end
  end
end
