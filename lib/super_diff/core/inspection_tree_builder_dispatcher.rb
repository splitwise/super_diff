module SuperDiff
  module Core
    class InspectionTreeBuilderDispatcher
      extend AttrExtras.mixin

      method_object :object, [:available_classes]

      def call
        if resolved_class
          resolved_class.call(object)
        else
          raise NoInspectionTreeBuilderAvailableError.create(object)
        end
      end

      private

      def resolved_class
        available_classes.find { |klass| klass.applies_to?(object) }
      end
    end
  end
end
