module SuperDiff
  module Differs
    class Array < Base
      def self.applies_to?(expected, actual)
        expected.is_a?(::Array) && actual.is_a?(::Array)
      end

      private

      def operational_sequencer_class
        OperationalSequencers::Array
      end
    end
  end
end
