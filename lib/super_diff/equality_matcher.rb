module SuperDiff
  class EqualityMatcher
    extend AttrExtras.mixin

    method_object(
      [
        :expected!,
        :actual!,
        extra_classes: [],
        extra_operational_sequencer_classes: [],
        extra_diff_formatter_classes: [],
      ]
    )

    def call
      resolved_class.call(
        expected: expected,
        actual: actual,
        extra_operational_sequencer_classes: extra_operational_sequencer_classes,
        extra_diff_formatter_classes: extra_diff_formatter_classes,
      )
    end

    private

    def resolved_class
      matching_class || EqualityMatchers::Object
    end

    def matching_class
      (EqualityMatchers::DEFAULTS + extra_classes).find do |klass|
        klass.applies_to?(expected) && klass.applies_to?(actual)
      end
    end
  end
end
