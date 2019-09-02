require_relative "csi/reset_sequence"

# Source: <https://en.wikipedia.org/wiki/ANSI_escape_code>
module SuperDiff
  module Csi
    def self.reset_sequence
      ResetSequence.new
    end

    def self.colorize(*args, **opts, &block)
      if block
        ColorizedDocument.new(&block)
      else
        ColorizedDocument.new { colorize(*args, **opts) }
      end
    end

    def self.decolorize(text)
      text.gsub(/\e\[\d+(?:;\d+)*m(.+?)\e\[0m/, '\1')
    end

    def self.inspect_colors_in(text)
      [FourBitColor, EightBitColor, TwentyFourBitColor].
        reduce(text) do |str, klass|
          klass.sub_colorized_areas_in(str) do |area, color|
            color_block = colorize("◼︎", color.to_foreground)

            layer_indicator =
              if color.foreground?
                "(fg)"
              else
                "(bg)"
              end

            "#{color_block} #{layer_indicator} ❮#{area}❯"
          end
        end
    end
  end
end

require_relative "csi/color"
require_relative "csi/eight_bit_color"
require_relative "csi/four_bit_color"
require_relative "csi/twenty_four_bit_color"
require_relative "csi/colorized_document"
