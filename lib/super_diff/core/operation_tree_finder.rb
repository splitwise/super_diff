# frozen_string_literal: true

module SuperDiff
  module Core
    class OperationTreeFinder
      extend AttrExtras.mixin

      method_object :value, [:available_classes]

      def call
        raise NoOperationTreeAvailableError.create(value) unless resolved_class

        begin
          resolved_class.new([], underlying_object: value)
        rescue ArgumentError
          resolved_class.new([])
        end
      end

      private

      def resolved_class
        available_classes.find { |klass| klass.applies_to?(value) }
      end
    end
  end
end
