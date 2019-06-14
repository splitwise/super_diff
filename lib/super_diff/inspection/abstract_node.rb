module SuperDiff
  module Inspection
    class AbstractNode
      def self.wrap(unknown)
        if unknown.is_a?(AbstractNode)
          unknown
        else
          new(unknown)
        end
      end

      def self.call(level:, value:, prefix: nil)
        new(level: level, value: value, prefix: prefix).call
      end

      attr_reader :level, :value, :prefix

      def initialize(level:, value:, prefix: nil)
        @level = level
        @value = value
        @prefix = prefix
      end

      def with_prefix(prefix)
        self.class.new(level: level, value: value, prefix: prefix)
      end

      def opening?
        false
      end

      def middle?
        false
      end

      def closing?
        false
      end

      def ==(other)
        tree = self.class.wrap(other)
        level == tree.level && value == tree.value && prefix == tree.prefix
      end
    end
  end
end
