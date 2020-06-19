module SuperDiff
  module ObjectInspection
    module InspectionTreeBuilders
      class Base
        extend AttrExtras.mixin
        extend ImplementationChecks
        include ImplementationChecks

        def self.applies_to?(_value)
          unimplemented_class_method!
        end

        method_object :object

        def call
          unimplemented_instance_method!
        end

        protected

        def inspection_tree
          unimplemented_instance_method!
        end
      end
    end
  end
end
