# frozen_string_literal: true

module SuperDiff
  module ActiveRecord
    module OperationTreeBuilders
      class ActiveRecordModel < Basic::OperationTreeBuilders::CustomObject
        def self.applies_to?(expected, actual)
          expected.is_a?(::ActiveRecord::Base) &&
            actual.is_a?(::ActiveRecord::Base) && expected.instance_of?(actual.class)
        end

        protected

        def id
          expected.class.primary_key
        end

        def attribute_names
          [id] + (expected.attributes.keys.sort - [id])
        end
      end
    end
  end
end
