module SuperDiff
  module Test
    class PersonDiffFormatter < ::SuperDiff::DiffFormatters::Object
      def self.applies_to?(operations)
        operations.is_a?(PersonOperationSequence)
      end

      protected

      def value_class
        SuperDiff::Test::Person
      end
    end
  end
end
