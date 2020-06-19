module SuperDiff
  module ObjectInspection
    module InspectionTreeBuilders
      class Main
        extend AttrExtras.mixin

        method_object :object

        def call
          if resolved_class
            resolved_class.call(object)
          else
            raise NoInspectorAvailableError.create(object)
          end
        end

        private

        def resolved_class
          available_classes.find { |klass| klass.applies_to?(object) }
        end

        def available_classes
          SuperDiff.configuration.extra_inspection_tree_builder_classes +
            DEFAULTS
        end
      end
    end
  end
end
