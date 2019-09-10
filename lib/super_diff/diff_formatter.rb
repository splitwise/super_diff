module SuperDiff
  class DiffFormatter
    extend AttrExtras.mixin

    method_object(
      :operations,
      [
        :indent_level!,
        add_comma: false,
        extra_classes: [],
      ],
    )

    def call
      resolved_class.call(
        operations,
        indent_level: indent_level,
        add_comma: add_comma?,
      )
    end

    private

    attr_query :add_comma?

    def resolved_class
      (DiffFormatters::DEFAULTS + extra_classes).find do |klass|
        klass.applies_to?(operations)
      end
    end
  end
end
