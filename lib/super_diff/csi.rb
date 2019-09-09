# Source: <https://en.wikipedia.org/wiki/ANSI_escape_code>
module SuperDiff
  module Csi
    autoload :Color, "super_diff/csi/color"
    autoload :ColorizedDocument, "super_diff/csi/colorized_document"
    autoload :EightBitColor, "super_diff/csi/eight_bit_color"
    autoload :FourBitColor, "super_diff/csi/four_bit_color"
    autoload :ResetSequence, "super_diff/csi/reset_sequence"
    autoload :TwentyFourBitColor, "super_diff/csi/twenty_four_bit_color"

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
