module SuperDiff
  module ObjectInspection
    class InspectorRegistry
      def initialize(contents = {})
        @contents = contents
      end

      def initialize_copy(other)
        super
        @contents = other.to_h.dup
      end

      def define(name, &definition)
        contents[name] = InspectionTree.new(&definition)
      end

      def find(object)
        contents.fetch(type_for(object))
      end

      def to_h
        contents
      end

      private

      attr_reader :contents

      def type_for(object)
        if object.respond_to?(:attributes_for_super_diff)
          :custom_object
        else
          case object
          when Array then :array
          when Hash then :hash
          when String then :string
          when true, false, nil, Symbol, Numeric, Regexp then :primitive
          else :default_object
          end
        end
      end
    end
  end
end
