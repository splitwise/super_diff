module SuperDiff
  module OperationTreeFlatteners
    class Base
      include ImplementationChecks
      extend AttrExtras.mixin

      method_object :operation_tree, [indentation_level: 0]

      def call
        beginning_lines + middle_lines + ending_lines
      end

      protected

      def build_tiered_lines
        unimplemented_instance_method!
      end

      private

      def beginning_lines
        if tiered_lines.empty?
          []
        elsif indentation_level > 0
          [tiered_lines[0]]
        else
          [tiered_lines[0].with_complete_bookend(:open)]
        end
      end

      def middle_lines
        if tiered_lines.empty?
          []
        else
          tiered_lines[1..-2]
        end
      end

      def ending_lines
        if tiered_lines.empty?
          []
        elsif indentation_level > 0
          [tiered_lines[-1]]
        else
          [tiered_lines[-1].with_complete_bookend(:close)]
        end
      end

      def tiered_lines
        @_tiered_lines ||= build_tiered_lines
      end
    end
  end
end
