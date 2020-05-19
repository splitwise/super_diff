module SuperDiff
  module Differs
    class DefaultObject < Base
      def self.applies_to?(expected, actual)
        expected.class == actual.class
      end

      private

      def operations
        OperationalSequencers::Main.call(
          expected: expected,
          actual: actual,
          all_or_nothing: true,
        )
      end
    end
  end
end
