module SuperDiff
  module RSpec
    module Differs
      class ObjectHavingAttributes < SuperDiff::Differs::DefaultObject
        def self.applies_to?(expected, _actual)
          SuperDiff::RSpec.an_object_having_some_attributes?(expected)
        end

        private

        def operational_sequencer_class
          OperationalSequencers::ObjectHavingAttributes
        end
      end
    end
  end
end
