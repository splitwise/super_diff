module SuperDiff
  module Differs
    class CustomObject < Base
      def self.applies_to?(expected, actual)
        expected.class == actual.class &&
          expected.respond_to?(:attributes_for_super_diff) &&
          actual.respond_to?(:attributes_for_super_diff)
      end

      private

      def operational_sequencer_class
        OperationalSequencers::CustomObject
      end
    end
  end
end
