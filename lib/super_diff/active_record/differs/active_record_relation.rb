module SuperDiff
  module ActiveRecord
    module Differs
      class ActiveRecordRelation < SuperDiff::Differs::Base
        def self.applies_to?(expected, actual)
          expected.is_a?(::Array) &&
            actual.is_a?(::ActiveRecord::Relation)
        end

        def call
          DiffFormatters::ActiveRecordRelation.call(
            operations,
            indent_level: indent_level,
          )
        end

        private

        def operations
          OperationalSequencers::ActiveRecordRelation.call(
            expected: expected,
            actual: actual,
          )
        end
      end
    end
  end
end
