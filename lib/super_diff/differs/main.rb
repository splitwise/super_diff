module SuperDiff
  module Differs
    class Main
      extend AttrExtras.mixin

      method_object(
        :expected,
        :actual,
        [
          indent_level: 0,
          omit_empty: false,
        ],
      )

      def call
        if resolved_class
          resolved_class.call(expected, actual, indent_level: indent_level)
        else
          raise Errors::NoDifferAvailableError.create(expected, actual)
        end
      end

      private

      attr_query :omit_empty?

      def resolved_class
        available_classes.find { |klass| klass.applies_to?(expected, actual) }
      end

      def available_classes
        classes = SuperDiff.configuration.extra_differ_classes + DEFAULTS

        if omit_empty?
          classes
        else
          classes + [Empty]
        end
      end
    end
  end
end
