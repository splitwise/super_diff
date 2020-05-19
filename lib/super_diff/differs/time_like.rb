module SuperDiff
  module Differs
    class TimeLike < Base
      def self.applies_to?(expected, actual)
        SuperDiff.time_like?(expected) && SuperDiff.time_like?(actual)
      end

      private

      def operational_sequencer_class
        OperationalSequencers::TimeLike
      end
    end
  end
end
