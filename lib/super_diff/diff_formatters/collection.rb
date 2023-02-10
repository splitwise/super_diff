module SuperDiff
  module DiffFormatters
    class Collection
      extend AttrExtras.mixin

      ICONS = { delete: "-", insert: "+" }.freeze
      STYLES = { insert: :actual, delete: :expected, noop: :plain }.freeze

      method_object(
        %i[
          open_token!
          close_token!
          operation_tree!
          indent_level!
          add_comma!
          collection_prefix!
          build_item_prefix!
        ]
      )

      def call
        lines.join("\n")
      end

      private

      attr_query :add_comma?

      def lines
        [
          "  #{indentation}#{collection_prefix}#{open_token}",
          *contents,
          "  #{indentation}#{close_token}#{comma}"
        ]
      end

      def contents
        operation_tree.map do |operation|
          if operation.name == :change
            handle_change_operation(operation)
          else
            handle_non_change_operation(operation)
          end
        end
      end

      def handle_change_operation(operation)
        SuperDiff::RecursionGuard.guarding_recursion_of(
          operation.left_collection,
          operation.right_collection
        ) do |already_seen|
          if already_seen
            raise "Infinite recursion!"
          else
            operation.child_operations.to_diff(
              indent_level: indent_level + 1,
              collection_prefix: build_item_prefix.call(operation),
              add_comma: operation.should_add_comma_after_displaying?
            )
          end
        end
      end

      def handle_non_change_operation(operation)
        icon = ICONS.fetch(operation.name, " ")
        style_name = STYLES.fetch(operation.name, :normal)
        chunk =
          build_chunk_for(
            operation,
            prefix: build_item_prefix.call(operation),
            icon: icon
          )

        chunk << "," if operation.should_add_comma_after_displaying?

        style_chunk(style_name, chunk)
      end

      def build_chunk_for(operation, prefix:, icon:)
        if operation.value.equal?(operation.collection)
          build_chunk_from_string(
            SuperDiff::RecursionGuard::PLACEHOLDER,
            prefix: build_item_prefix.call(operation),
            icon: icon
          )
        else
          build_chunk_by_inspecting(
            operation.value,
            prefix: build_item_prefix.call(operation),
            icon: icon
          )
        end
      end

      def build_chunk_by_inspecting(value, prefix:, icon:)
        inspection = SuperDiff.inspect_object(value, as_single_line: false)
        build_chunk_from_string(inspection, prefix: prefix, icon: icon)
      end

      def build_chunk_from_string(value, prefix:, icon:)
        value
          .split("\n")
          .map
          .with_index do |line, index|
            [
              icon,
              " ",
              indentation(offset: 1),
              (index == 0 ? prefix : ""),
              line
            ].join
          end
          .join("\n")
      end

      def style_chunk(style_name, chunk)
        chunk
          .split("\n")
          .map { |line| Helpers.style(style_name, line) }
          .join("\n")
      end

      def indentation(offset: 0)
        "  " * (indent_level + offset)
      end

      def comma
        add_comma? ? "," : ""
      end
    end
  end
end
