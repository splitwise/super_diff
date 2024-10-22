# frozen_string_literal: true

module SuperDiff
  module Core
    class OperationTreeBuilderDispatcher
      extend AttrExtras.mixin

      method_object(
        :expected,
        :actual,
        [:available_classes, { raise_if_nothing_applies: true }]
      )

      def call
        if resolved_class
          resolved_class.call(expected: expected, actual: actual)
        elsif raise_if_nothing_applies?
          raise NoOperationTreeBuilderAvailableError.create(expected, actual)
        end
      end

      private

      attr_query :raise_if_nothing_applies?

      def resolved_class
        available_classes.find { |klass| klass.applies_to?(expected, actual) }
      end
    end
  end
end
