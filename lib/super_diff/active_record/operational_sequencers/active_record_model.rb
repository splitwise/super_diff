module SuperDiff
  module ActiveRecord
    module OperationalSequencers
      class ActiveRecordModel < SuperDiff::OperationalSequencers::Object
        def self.applies_to?(expected, actual)
          expected.is_a?(::ActiveRecord::Base) &&
            actual.is_a?(::ActiveRecord::Base) &&
            expected.class == actual.class
        end

        protected

        def attribute_names
          ["id"] + (expected.attributes.keys.sort - ["id"])
        end

        private

        def establish_expected_and_actual_attributes
          @expected_attributes = attribute_names.reduce({}) do |hash, name|
            hash.merge(name => expected.read_attribute(name))
          end

          @actual_attributes = attribute_names.reduce({}) do |hash, name|
            hash.merge(name => actual.read_attribute(name))
          end
        end
      end
    end
  end
end
