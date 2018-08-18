module SuperDiff
  module Csi
    module ColorHelper
      BLACK = Csi::FourBitColor.new(:white)
      # LIGHT_RED = Csi::TwentyFourBitColor.new(r: 63, g: 32, b: 32)
      LIGHT_RED = Csi::TwentyFourBitColor.new(r: 73, g: 62, b: 71)
      # RED = Csi::TwentyFourBitColor.new(r: 110, g: 56, b: 56)
      # RED = Csi::TwentyFourBitColor.new(r: 116, g: 78, b: 84)
      RED = Csi::FourBitColor.new(:red)
      # LIGHT_GREEN = Csi::TwentyFourBitColor.new(r: 40, g: 48, b: 39)
      LIGHT_GREEN = Csi::TwentyFourBitColor.new(r: 51, g: 81, b: 81)
      # GREEN = Csi::TwentyFourBitColor.new(r: 73, g: 87, b: 71)
      # GREEN = Csi::TwentyFourBitColor.new(r: 81, g: 115, b: 105)
      GREEN = Csi::FourBitColor.new(:green)
      DARK_GREY = Csi::TwentyFourBitColor.new(r: 134, g: 147, b: 149)

      def self.plain(text)
        text
      end

      def self.line(given_text = "")
        if block_given?
          text = ""
          yield text
          text + "\n"
        else
          given_text + "\n"
        end
      end

      def self.light_red_bg(text)
        Csi.colorize(text, fg: BLACK, bg: LIGHT_RED)
      end

      def self.red(text)
        Csi.colorize(text, fg: RED)
      end

      def self.light_green_bg(text)
        Csi.colorize(text, fg: BLACK, bg: LIGHT_GREEN)
      end

      def self.green(text)
        Csi.colorize(text, fg: GREEN)
      end

      def self.dark_grey(text)
        Csi.colorize(text, fg: BLACK, bg: DARK_GREY)
      end
    end
  end
end
