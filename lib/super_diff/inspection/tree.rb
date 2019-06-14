module SuperDiff
  module Inspection
    class Tree
      include Enumerable

      def initialize(nodes, prefix: nil)
        @nodes = nodes
        @prefix = prefix
      end

      def with_prefix(prefix)
        self.class.new(nodes.map(&:clone), prefix: prefix)
      end

      def each(&block)
        if prefix
          # Assume that the first node is an OpeningNode
          ([nodes[0].with_prefix(prefix)] + nodes[1..-1]).each(&block)
        else
          nodes.each(&block)
        end
      end

      def ==(other)
        other.is_a?(self.class) && nodes == other.to_a
      end

      def to_lines(indent_level:)
        nodes.map do |node|
          line = indentation_at(indent_level + node.level)

          if node.level.zero? && prefix && node.opening?
            line << prefix
          end

          line << node.value

          if node.middle? && !node.last_item_in_middle?
            line << ","
          end

          line
        end
      end

      private

      attr_reader :nodes, :prefix

      def indentation_at(level)
        " " * (level * 2)
      end
    end
  end
end
