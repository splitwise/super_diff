module SuperDiff
  module Differs
    class Hash < Base
      def self.applies_to?(expected, actual)
        expected.is_a?(::Hash) && actual.is_a?(::Hash)
      end

      private

      def operational_sequencer_class
        OperationalSequencers::Hash
      end
    end
  end
end
