module SuperDiff
  module ObjectInspection
    module Inspectors
      class Main
        extend AttrExtras.mixin

        method_object :object, [:as_single_line!, :indent_level!]

        def call
          if resolved_class
            resolved_class.call(
              object,
              as_single_line: as_single_line?,
              indent_level: indent_level,
            )
          else
            raise NoInspectorAvailableError.create(object)
          end
        end

        private

        attr_query :as_single_line?

        def resolved_class
          available_classes.find { |klass| klass.applies_to?(object) }
        end

        def available_classes
          SuperDiff.configuration.extra_inspector_classes + DEFAULTS
        end
      end
    end
  end
end
