require_relative "base"

module SuperDiff
  module Differs
    class Collection < Base
      protected

      def events
        raise NotImplementedError
      end

      def build_diff(open, close, &block)
        ["  #{open}", *build_diff_contents(&block), "  #{close}"].join("\n")
      end

      def build_diff_contents(&block)
        events.map do |event|
          index = event[:index]
          collection = event[:collection]

          icon = ICONS.fetch(event[:state], " ")
          style_name = STYLES.fetch(event[:state], :normal)
          chunk = build_chunk(
            block.call(event),
            indent: 4,
            icon: icon
          )

          if index < collection.length - 1
            chunk << ","
          end

          style_chunk(style_name, chunk)
        end
      end

      private

      def build_chunk(text, indent:, icon:)
        text
          .split("\n")
          .map { |line| icon + (" " * (indent - 1)) + line }
          .join("\n")
      end

      def style_chunk(style_name, chunk)
        chunk.split("\n").map { |line| style(style_name, line) }.join("\n")
      end
    end
  end
end
