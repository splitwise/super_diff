module SuperDiff
  module ActiveRecord
    module OperationalSequencers
      class ActiveRecordModel < SuperDiff::OperationalSequencers::CustomObject
        def self.applies_to?(expected, actual)
          expected.is_a?(::ActiveRecord::Base) &&
            actual.is_a?(::ActiveRecord::Base) &&
            expected.class == actual.class
        end

        protected

        def attribute_names
          ["id"] + (expected.attributes.keys.sort - ["id"])
        end
      end
    end
  end
end
