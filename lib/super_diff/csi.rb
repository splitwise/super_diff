require_relative "csi/reset_sequence"

# Source: <https://en.wikipedia.org/wiki/ANSI_escape_code>
module SuperDiff
  module Csi
    def self.reset_sequence
      ResetSequence.new
    end

    def self.colorize(text, fg: nil, bg: nil)
      parts = []

      if fg
        parts << fg.sequence_for(:fg)
      end

      if bg
        parts << bg.sequence_for(:bg)
      end

      (parts + [text, reset_sequence]).join
    end

    def self.decolorize(text)
      text.gsub(/\e\[\d+m(.+?)\e\[0m/, '\1')
    end
  end
end

require_relative "csi/four_bit_color"
require_relative "csi/eight_bit_color"
require_relative "csi/twenty_four_bit_color"
require_relative "csi/color_helper"
