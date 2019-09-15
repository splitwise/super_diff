module SuperDiff
  module Helpers
    # TODO: Simplify this
    def self.style(*args, color_enabled: true, **opts, &block)
      klass =
        if color_enabled && Csi.color_enabled?
          Csi::ColorizedDocument
        else
          Csi::UncolorizedDocument
        end

      document = klass.new.extend(ColorizedDocumentExtensions)

      if block
        document.__send__(:evaluate_block, &block)
      else
        document.colorize(*args, **opts)
      end

      document
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
