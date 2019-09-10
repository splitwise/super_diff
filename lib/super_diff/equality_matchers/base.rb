module SuperDiff
  module EqualityMatchers
    class Base
      def self.applies_to?(_value)
        raise NotImplementedError
      end

      extend AttrExtras.mixin

      method_object(
        [
          :expected!,
          :actual!,
          extra_operational_sequencer_classes: [],
          extra_diff_formatter_classes: [],
        ]
      )

      def call
        if expected == actual
          ""
        else
          fail
        end
      end

      protected

      def fail
        raise NotImplementedError
      end
    end
  end
end
