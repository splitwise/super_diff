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
        "#<Person name=#{name.inspect}>"
      end
    end
  end
end
