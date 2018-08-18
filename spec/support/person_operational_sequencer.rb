module SuperDiff
  module Test
    class PersonOperationalSequencer < ::SuperDiff::OperationalSequencers::Object
      def self.applies_to?(value)
        value.is_a?(Person)
      end

      protected

      def operation_sequence_class
        PersonOperationSequence
      end

      def attribute_names
        [:name]
      end
    end
  end
end
