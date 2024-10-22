# frozen_string_literal: true

module SuperDiff
  module Core
    class DifferDispatcher
      extend AttrExtras.mixin

      method_object(
        :expected,
        :actual,
        [:available_classes, { indent_level: 0, raise_if_nothing_applies: true }]
      )

      def call
        if resolved_class
          resolved_class.call(expected, actual, indent_level: indent_level)
        elsif raise_if_nothing_applies?
          raise NoDifferAvailableError.create(expected, actual)
        else
          ''
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
