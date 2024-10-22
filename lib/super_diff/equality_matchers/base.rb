# frozen_string_literal: true

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
          { extra_operation_tree_builder_classes: [],
            extra_diff_formatter_classes: [] }
        ]
      )

      def call
        fail unless expected == actual

        ''
      end

      protected

      def fail
        raise NotImplementedError
      end
    end
  end
end
