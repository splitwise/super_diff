module SuperDiff
  module Inspection
    class BuildTree
      def self.call(args)
        new(args).call
      end

      def initialize(opening:, middle:, closing:, level: 0)
        @opening = opening
        @middle = middle
        @closing = closing
        @level = level
      end

      def call
        Tree.new([
          OpeningNode.new(
            level: level,
            value: opening,
          ),
          *flattened_middle,
          ClosingNode.new(
            level: level,
            value: closing,
          ),
        ])
      end

      private

      attr_reader :opening, :middle, :closing, :level

      def flattened_middle
        middle.flat_map.with_index do |pair, i|
          if pair.value.is_a?(Tree)
            pair.value.with_prefix(pair.as_prefix).to_a
          else
            MiddleNode.new(
              level: level + 1,
              prefix: pair.as_prefix,
              value: pair.value,
              first_item_in_middle: i.zero?,
              last_item_in_middle: (i == middle.size - 1),
            )
          end
        end
      end
    end
  end
end
