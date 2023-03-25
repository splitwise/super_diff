module SuperDiff
  module OperationTreeBuilders
    class Main
      extend AttrExtras.mixin

      method_object %i[expected! actual! all_or_nothing!]

      def call
        if resolved_class
          resolved_class.call(expected: expected, actual: actual)
        elsif all_or_nothing?
          raise NoOperationTreeBuilderAvailableError.create(expected, actual)
        else
          nil
        end
      end

      private

      attr_query :all_or_nothing?

      def resolved_class
        available_classes.find { |klass| klass.applies_to?(expected, actual) }
      end

      def available_classes
        classes =
          SuperDiff.configuration.extra_operation_tree_builder_classes +
            DEFAULTS

        all_or_nothing? ? classes + [DefaultObject] : classes
      end
    end
  end
end
