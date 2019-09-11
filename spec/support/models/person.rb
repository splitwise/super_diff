module SuperDiff
  module Test
    class Person
      attr_reader :name, :age

      def initialize(name:, age:)
        @name = name
        @age = age
      end

      def ==(other)
        other.is_a?(self.class) && other.name == name && other.age == age
      end

      def attributes_for_super_diff
        { name: name, age: age }
      end
    end
  end
end
