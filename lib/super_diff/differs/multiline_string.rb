module SuperDiff
  module Differs
    class MultilineString < Base
      def self.applies_to?(expected, actual)
        expected.is_a?(::String) && actual.is_a?(::String) &&
          (expected.include?("\n") || actual.include?("\n"))
      end

      private

      def operational_sequencer_class
        OperationalSequencers::MultilineString
      end
    end
  end
end
