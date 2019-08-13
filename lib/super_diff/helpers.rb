module SuperDiff
  module Helpers
    COLORS = { normal: :plain, inserted: :green, deleted: :red }.freeze

    def self.style(style_name, text)
      Csi::ColorHelper.public_send(COLORS.fetch(style_name), text)
    end

    def self.plural_type_for(value)
      case value
      when Numeric then "numbers"
      when String then "strings"
      when Symbol then "symbols"
      else "objects"
      end
    end
  end
end
