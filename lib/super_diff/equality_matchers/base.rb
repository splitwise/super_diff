module SuperDiff
  module EqualityMatchers
    class Base
      def self.applies_to?(_value)
        raise NotImplementedError
      end

      def self.call(*args)
        new(*args).call
      end

      def initialize(
        expected:,
        actual:,
        extra_operational_sequencer_classes: [],
        extra_diff_formatter_classes: []
      )
        @expected = expected
        @actual = actual
        @extra_operational_sequencer_classes = extra_operational_sequencer_classes
        @extra_diff_formatter_classes = extra_diff_formatter_classes
      end

      def call
        if Helpers.values_equal?(expected, actual)
          ""
        else
          fail
        end
      end

      protected

      attr_reader :expected, :actual, :extra_operational_sequencer_classes,
        :extra_diff_formatter_classes

      def fail
        raise NotImplementedError
      end
    end
  end
end
