# frozen_string_literal: true

module SuperDiff
  module Core
    class InspectionTreeBuilderDispatcher
      extend AttrExtras.mixin

      method_object :object, [:available_classes]

      def call
        raise NoInspectionTreeBuilderAvailableError.create(object) unless resolved_class

        resolved_class.call(object)
      end

      private

      def resolved_class
        available_classes.find { |klass| klass.applies_to?(object) }
      end
    end
  end
end
