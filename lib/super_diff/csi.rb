# Source: <https://en.wikipedia.org/wiki/ANSI_escape_code>
module SuperDiff
  module Csi
    autoload :BoldSequence, "super_diff/csi/bold_sequence"
    autoload :Color, "super_diff/csi/color"
    autoload :ColorSequenceBlock, "super_diff/csi/color_sequence_block"
    autoload :ColorizedDocument, "super_diff/csi/colorized_document"
    autoload :Document, "super_diff/csi/document"
    autoload :EightBitColor, "super_diff/csi/eight_bit_color"
    autoload :FourBitColor, "super_diff/csi/four_bit_color"
    autoload :ResetSequence, "super_diff/csi/reset_sequence"
    autoload :TwentyFourBitColor, "super_diff/csi/twenty_four_bit_color"
    autoload :UncolorizedDocument, "super_diff/csi/uncolorized_document"

    class << self
      attr_writer :color_enabled
    end

    def self.reset_sequence
      ResetSequence.new
    end

    def self.color_enabled?
      @color_enabled
    end

    def self.colorize(*args, **opts, &block)
      if color_enabled?
        ColorizedDocument.new(*args, **opts, &block)
      else
        UncolorizedDocument.new(*args, **opts, &block)
      end
    end

    def self.decolorize(text)
      text.gsub(/\e\[\d+(?:;\d+)*m(.+?)\e\[0m/, '\1')
    end

    def self.already_colorized?(text)
      text.match?(/\e\[\d+m/)
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

    self.color_enabled = false
  end
end
