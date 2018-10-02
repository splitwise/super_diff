module SuperDiff
  module Tests
    class Colorizer < BasicObject
      def self.call(&block)
        new.instance_eval(&block).to_s
      end

      def initialize
        @string = ""
      end

      def method_missing(name, *args, &block)
        match = name.match(/\A(.+)_line\Z/)

        if match
          real_name = match.captures[0]

          if Csi::ColorHelper.respond_to?(real_name)
            addition = Csi::ColorHelper.public_send(real_name, *args)

            if match
              addition << "\n"
            end

            @string << addition
          else
            super
          end
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        match = name.match(/\A(.+)_line\Z/)

        if match
          Csi::ColorHelper.respond_to?(match.captures[0]) || super
        else
          super
        end
      end

      def to_s
        @string.strip
      end
    end
  end
end
