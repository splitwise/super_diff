module SuperDiff
  module Differs
    class Time < Base
      def self.applies_to?(expected, actual)
        OperationalSequencers::TimeLike.applies_to?(expected, actual)
      end

      private

      def operational_sequencer_class
        OperationalSequencers::TimeLike
      end
    end
  end
end
