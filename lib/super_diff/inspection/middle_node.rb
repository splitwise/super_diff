module SuperDiff
  module Inspection
    class MiddleNode < AbstractNode
      def self.call(first_item_in_middle:, last_item_in_middle:, **rest)
        new(
          first_item_in_middle: first_item_in_middle,
          last_item_in_middle: last_item_in_middle,
          **rest,
        ).call
      end

      def initialize(first_item_in_middle:, last_item_in_middle:, **rest)
        super(**rest)

        @first_item_in_middle = first_item_in_middle
        @last_item_in_middle = last_item_in_middle
      end

      def middle?
        true
      end

      def first_item_in_middle?
        @first_item_in_middle
      end

      def last_item_in_middle?
        @last_item_in_middle
      end

      def ==(other)
        tree = self.class.wrap(other)

        super &&
          first_item_in_middle? == tree.first_item_in_middle? &&
          last_item_in_middle? == tree.last_item_in_middle?
      end
    end
  end
end
