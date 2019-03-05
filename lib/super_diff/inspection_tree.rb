module SuperDiff
  class InspectionTree
    include Enumerable

    def initialize(nodes)
      @nodes = nodes.map do |node|
        if node.is_a?(Hash)
          if node[:location] == "middle"
            MiddleNode.new(node)
          else
            BookendNode.new(node)
          end
        else
          node
        end
      end
    end

    def each(&block)
      nodes.each(&block)
    end

    def ==(other)
      nodes == other.to_a
    end

    private

    attr_reader :nodes

    class AbstractNode
      def self.wrap(unknown)
        if unknown.is_a?(self)
          unknown
        else
          new(unknown)
        end
      end

      def self.call(level:, value:, location:)
        new(level: level, value: value, location: location).call
      end

      attr_reader :level, :value, :location

      def initialize(level:, value:, location:)
        @level = level
        @value = value
        @location = location
      end

      def ==(other)
        tree = self.class.wrap(other)

        level == tree.level &&
          value == tree.value &&
          location == tree.location
      end
    end

    class BookendNode < AbstractNode
    end

    class MiddleNode < AbstractNode
      def self.call(first_item:, last_item:, **rest)
        new(first_item: first_item, last_item: last_item, **rest).call
      end

      def initialize(first_item:, last_item:, **rest)
        super(**rest)

        @first_item = first_item
        @last_item = last_item
      end

      def first_item?
        @first_item
      end

      def last_item?
        @last_item
      end

      def ==(other)
        tree = self.class.wrap(other)

        super &&
          first_item? == tree.first_item? &&
          last_item? == tree.last_item?
      end
    end
  end
end
