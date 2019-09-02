module SuperDiff
  module Helpers
    def self.style(*args, **opts, &block)
      SuperDiff::ColorizedDocument.colorize(*args, **opts, &block)
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
