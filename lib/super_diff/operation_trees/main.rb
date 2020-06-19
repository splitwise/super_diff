module SuperDiff
  module OperationTrees
    class Main
      extend AttrExtras.mixin

      method_object :value

      def call
        if resolved_class
          begin
            resolved_class.new([], underlying_object: value)
          rescue ArgumentError
            resolved_class.new([])
          end
        else
          raise Errors::NoOperationalSequenceAvailableError.create(value)
        end
      end

      private

      def resolved_class
        if value.respond_to?(:attributes_for_super_diff)
          CustomObject
        else
          available_classes.find { |klass| klass.applies_to?(value) }
        end
      end

      def available_classes
        SuperDiff.configuration.extra_operation_tree_classes + DEFAULTS
      end
    end
  end
end
