# frozen_string_literal: true

module SuperDiff
  module EqualityMatchers
    class Main
      extend AttrExtras.mixin

      method_object [:expected!, :actual!, { extra_classes: [] }]

      def call
        resolved_class.call(expected: expected, actual: actual)
      end

      private

      def resolved_class
        (DEFAULTS + extra_classes).find do |klass|
          klass.applies_to?(expected) && klass.applies_to?(actual)
        end
      end
    end
  end
end
