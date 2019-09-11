module SuperDiff
  module Test
    class PersonOperationalSequencer < ::SuperDiff::OperationalSequencers::Object
      def self.applies_to?(expected, actual)
        expected.is_a?(Person) && actual.is_a?(Person)
      end

      protected

      def operation_sequence_class
        PersonOperationSequence
      end

      def attribute_names
        [:name, :age]
      end
    end
  end
end

SuperDiff::RSpec.configure do |config|
  config.add_extra_operational_sequencer_class(
    SuperDiff::Test::PersonOperationalSequencer,
  )
end
