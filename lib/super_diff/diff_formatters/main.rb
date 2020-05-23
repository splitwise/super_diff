module SuperDiff
  module DiffFormatters
    class Main
      extend AttrExtras.mixin

      method_object(
        :operation_tree,
        [
          :indent_level!,
          add_comma: false,
          value_class: nil,
        ],
      )

      def call
        if resolved_class
          resolved_class.call(
            operation_tree,
            indent_level: indent_level,
            add_comma: add_comma?,
            value_class: value_class,
          )
        else
          raise NoDiffFormatterAvailableError.create(operation_tree)
        end
      end

      private

      attr_query :add_comma?

      def resolved_class
        available_classes.find { |klass| klass.applies_to?(operation_tree) }
      end

      def available_classes
        DEFAULTS + SuperDiff.configuration.extra_diff_formatter_classes
      end
    end
  end
end
