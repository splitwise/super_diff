module SuperDiff
  module OperationTreeFlatteners
    class Collection < Base
      protected

      def build_tiered_lines
        [
          Line.new(
            type: :noop,
            indentation_level: indentation_level,
            value: open_token,
            collection_bookend: :open
          ),
          *inner_lines,
          Line.new(
            type: :noop,
            indentation_level: indentation_level,
            value: close_token,
            collection_bookend: :close
          )
        ]
      end

      def inner_lines
        @_inner_lines ||=
          operation_tree.flat_map do |operation|
            lines =
              if operation.name == :change
                build_lines_for_change_operation(operation)
              else
                build_lines_for_non_change_operation(operation)
              end

            maybe_add_prefix_at_beginning_of_lines(
              maybe_add_comma_at_end_of_lines(lines, operation),
              operation
            )
          end
      end

      def maybe_add_prefix_at_beginning_of_lines(lines, operation)
        if add_prefix_at_beginning_of_lines?(operation)
          add_prefix_at_beginning_of_lines(lines, operation)
        else
          lines
        end
      end

      def add_prefix_at_beginning_of_lines?(operation)
        !!item_prefix_for(operation)
      end

      def add_prefix_at_beginning_of_lines(lines, operation)
        [lines[0].prefixed_with(item_prefix_for(operation))] + lines[1..-1]
      end

      def maybe_add_comma_at_end_of_lines(lines, operation)
        if last_item_in_collection?(operation)
          lines
        else
          add_comma_at_end_of_lines(lines)
        end
      end

      def last_item_in_collection?(operation)
        if operation.name == :change
          operation.left_index == operation.left_collection.size - 1 &&
            operation.right_index == operation.right_collection.size - 1
        else
          operation.index == operation.collection.size - 1
        end
      end

      def add_comma_at_end_of_lines(lines)
        lines[0..-2] + [lines[-1].with_comma]
      end

      def build_lines_for_change_operation(operation)
        SuperDiff::RecursionGuard.guarding_recursion_of(
          operation.left_collection,
          operation.right_collection
        ) do |already_seen|
          if already_seen
            raise InfiniteRecursionError
          else
            operation.children.flatten(indentation_level: indentation_level + 1)
          end
        end
      end

      def build_lines_for_non_change_operation(operation)
        indentation_level = @indentation_level + 1

        if recursive_operation?(operation)
          [
            Line.new(
              type: operation.name,
              indentation_level: indentation_level,
              value: SuperDiff::RecursionGuard::PLACEHOLDER
            )
          ]
        else
          build_lines_from_inspection_of(
            operation.value,
            type: operation.name,
            indentation_level: indentation_level
          )
        end
      end

      def recursive_operation?(operation)
        operation.value.equal?(operation.collection) ||
          SuperDiff::RecursionGuard.already_seen?(operation.value)
      end

      def item_prefix_for(_operation)
        ""
      end

      def build_lines_from_inspection_of(value, type:, indentation_level:)
        SuperDiff.inspect_object(
          value,
          as_lines: true,
          type: type,
          indentation_level: indentation_level
        )
      end

      class InfiniteRecursionError < StandardError
        def initialize(_message = nil)
          super("Unhandled recursive data structure encountered!")
        end
      end
    end
  end
end
