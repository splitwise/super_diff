module SuperDiff
  module ObjectInspection
    module Nodes
      def self.fetch(type)
        registry.fetch(type) do
          raise KeyError, "Could not find a node class for #{type.inspect}!"
        end
      end

      def self.registry
        @_registry ||= {}
      end

      def self.register(type, klass)
        registry[type] = klass
      end
    end
  end
end
