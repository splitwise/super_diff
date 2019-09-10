module SuperDiff
  module Differs
    class Base
      def self.applies_to?(_expected, _actual)
        raise NotImplementedError
      end

      extend AttrExtras.mixin

      method_object(
        :expected,
        :actual,
        [
          :indent_level!,
          index_in_collection: nil,
          extra_operational_sequencer_classes: [],
          extra_diff_formatter_classes: [],
        ],
      )

      def call
        raise NotImplementedError
      end

      protected

      def indentation
        " " * (indent_level * 2)
      end
    end
  end
end
