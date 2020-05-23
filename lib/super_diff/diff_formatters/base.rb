module SuperDiff
  module DiffFormatters
    class Base
      def self.applies_to?(*)
        raise NotImplementedError
      end

      include ImplementationChecks
      extend AttrExtras.mixin

      method_object(
        :operation_tree,
        [
          :indent_level!,
          collection_prefix: "",
          add_comma: false,
        ],
      )

      def call
        raise NotImplementedError
      end

      # rubocop:disable Lint/UselessAccessModifier

      private

      # rubocop:enable Lint/UselessAccessModifier

      attr_query :add_comma?
    end
  end
end
