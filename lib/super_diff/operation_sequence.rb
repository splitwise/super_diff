module SuperDiff
  class OperationSequence
    extend AttrExtras.mixin

    method_object :value, [extra_classes: []]

    def call
      if resolved_class
        begin
          resolved_class.new([], value_class: value.class)
        rescue ArgumentError
          resolved_class.new([])
        end
      else
        raise NoOperationalSequenceAvailableError.create(value)
      end
    end

    private

    def resolved_class
      if value.respond_to?(:attributes_for_super_diff)
        OperationSequences::CustomObject
      else
        available_classes.find { |klass| klass.applies_to?(value) }
      end
    end

    def available_classes
      extra_classes + OperationSequences::DEFAULTS
    end
  end
end
