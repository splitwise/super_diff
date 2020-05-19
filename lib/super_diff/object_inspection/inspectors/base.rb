module SuperDiff
  module ObjectInspection
    module Inspectors
      class Base
        extend AttrExtras.mixin
        extend ImplementationChecks

        def self.applies_to?(_value)
          unimplemented_class_method!
        end

        method_object :object, [:as_single_line!, :indent_level]

        def call
          SuperDiff::RecursionGuard.substituting_recursion_of(object) do
            inspection_tree.evaluate(
              object,
              as_single_line: as_single_line,
              indent_level: indent_level,
            )
          end
        end

        protected

        def inspection_tree
          unimplemented_instance_method!
        end

        private

        attr_query :as_single_line?
      end
    end
  end
end
