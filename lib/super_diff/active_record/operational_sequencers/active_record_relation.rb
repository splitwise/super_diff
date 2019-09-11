module SuperDiff
  module ActiveRecord
    module OperationalSequencers
      class ActiveRecordRelation < SuperDiff::OperationalSequencers::Array
        def self.applies_to?(expected, actual)
          expected.is_a?(::Array) &&
            actual.is_a?(::ActiveRecord::Relation)
        end

        def initialize(actual:, **rest)
          super

          @actual = actual.to_a
        end

        private

        def operations
          @_operations ||= OperationSequences::ActiveRecordRelation.new([])
        end
      end
    end
  end
end
