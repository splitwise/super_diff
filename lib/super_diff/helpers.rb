module SuperDiff
  module Helpers
    extend self

    # TODO: Simplify this
    def style(*args, color_enabled: true, **opts, &block)
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

    def plural_type_for(value)
      case value
      when Numeric then "numbers"
      when String then "strings"
      when Symbol then "symbols"
      else "objects"
      end
    end

    def jruby?
      defined?(JRUBY_VERSION)
    end

    def ruby_version_matches?(version_string)
      Gem::Requirement.new(version_string).satisfied_by?(
        Gem::Version.new(RUBY_VERSION),
      )
    end

    if jruby?
      def object_address_for(object)
        # Source: <https://github.com/jruby/jruby/blob/master/core/src/main/java/org/jruby/RubyBasicObject.java>
        "0x%x" % object.hash
      end
    elsif ruby_version_matches?(">= 2.7.0")
      require "json"
      require "objspace"

      def object_address_for(object)
        # Sources: <https://bugs.ruby-lang.org/issues/15408> and <https://bugs.ruby-lang.org/issues/15626#Object-ID>
        address = JSON.parse(ObjectSpace.dump(object))["address"]
        "0x%016x" % Integer(address, 16)
      end
    else
      def object_address_for(object)
        "0x%016x" % (object.object_id * 2)
      end
    end

    def with_slice_of_array_replaced(array, range, replacement)
      beginning =
        if range.begin > 0
          array[Range.new(0, range.begin - 1)]
        else
          []
        end

      ending =
        if range.end <= array.length - 1
          array[Range.new(range.end + 1, array.length - 1)]
        else
          []
        end

      beginning + [replacement] + ending
    end
  end
end
