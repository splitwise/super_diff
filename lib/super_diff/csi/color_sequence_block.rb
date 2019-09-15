module SuperDiff
  module Csi
    class ColorSequenceBlock
      include Enumerable

      def initialize(colors = [])
        @colors = colors
      end

      def each(&block)
        colors.each(&block)
      end

      def push(color)
        colors.push(color)
      end
      alias_method :<<, :push

      def to_s
        colors.map(&:to_s).join
      end

      private

      attr_reader :colors
    end
  end
end
