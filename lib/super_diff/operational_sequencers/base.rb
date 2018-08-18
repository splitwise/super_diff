module SuperDiff
  module OperationalSequencers
    class Base
      def self.call(expected, actual)
        new(expected, actual).call
      end

      def initialize(expected, actual)
        @expected = expected
        @actual = actual
      end

      def call
        raise NotImplementedError
      end

      private

      attr_reader :expected, :actual
    end
  end
end
