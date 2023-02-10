module SuperDiff
  module Csi
    class Color
      def self.exists?(name)
        FourBitColor.exists?(name)
      end

      def self.resolve(value, layer:)
        if value.is_a?(Symbol)
          FourBitColor.new(value, layer: layer)
        else
          TwentyFourBitColor.new(value, layer: layer)
        end
      end

      def self.sub_colorized_areas_in(text)
        regex = /(#{opening_regex.source.gsub(/\((.+?)\)/, '\1')})(.+?)\e\[0m/

        text.gsub(regex) do
          match = Regexp.last_match

          if match[1] == "\e[0m"
            match[0]
          else
            yield match[2], new(match[1])
          end
        end
      end

      def to_s
        raise NotImplementedError
      end

      def foreground?
        layer == :foreground
      end

      def background?
        layer == :background
      end

      def to_foreground
        raise NotImplementedError
      end

      protected

      attr_reader :layer

      def interpret_layer!(layer)
        if %i[foreground background].include?(layer)
          layer
        else
          raise ArgumentError.new(
                  "Invalid layer #{layer.inspect}. " +
                    "Layer must be :foreground or :background."
                )
        end
      end
    end
  end
end
