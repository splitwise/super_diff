module SuperDiff
  module Test
    class Person
      attr_reader :name

      def initialize(name:)
        @name = name
      end

      def ==(other)
        other.is_a?(self.class) && other.name == name
      end

      def inspect
        "#<#{self.class} name: #{name.inspect}>"
      end

      def attributes_for_super_diff
        { name: name }
      end
    end
  end
end
