module SuperDiff
  module ObjectInspection
    class Inspector
      extend AttrExtras.mixin

      method_object :map, :object, [:indent_level!, :as_single_line!]

      def call
        SuperDiff::RecursionGuard.substituting_recursion_of(object) do
          inspector.evaluate(
            object,
            as_single_line: as_single_line,
            indent_level: indent_level,
          )
        end
      end

      private

      attr_query :as_single_line?

      def inspector
        @_inspector ||= map.call(object)
      end
    end
  end
end
