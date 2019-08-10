module SuperDiff
  module ObjectInspection
    module Inspectors
      def self.define(name, &definition)
        registry[name] = InspectionTree.new(&definition)
      end

      def self.registry
        @_registry ||= {}
      end

      def self.find(object)
        registry.fetch(inspector_type_for(object))
      end

      def self.inspector_type_for(object)
        if object.respond_to?(:attributes_for_super_diff)
          :custom_object
        else
          case object
          when Array then :array
          when Hash then :hash
          when String then :string
          when Symbol, Numeric, true, false, nil then :primitive
          else :default_object
          end
        end
      end

      private_class_method :registry
    end
  end
end
