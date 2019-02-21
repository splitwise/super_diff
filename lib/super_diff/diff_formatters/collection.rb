module SuperDiff
  module DiffFormatters
    class Collection
      ICONS = { delete: "-", insert: "+" }.freeze
      STYLES = { insert: :inserted, delete: :deleted, noop: :normal }.freeze

      def self.call(*args, &block)
        new(*args, &block).call
      end

      def initialize(
        open_token:,
        close_token:,
        operations:,
        indent_level:,
        add_comma:,
        collection_prefix:,
        build_item_prefix:
      )
        @open_token = open_token
        @close_token = close_token
        @operations = operations
        @indent_level = indent_level
        @add_comma = add_comma
        @collection_prefix = collection_prefix
        @build_item_prefix = build_item_prefix
      end

      def call
        lines.join("\n")
      end

      private

      attr_reader :open_token, :close_token, :operations, :indent_level,
        :add_comma, :collection_prefix, :build_item_prefix

      def lines
        [
          "  #{indentation}#{collection_prefix}#{open_token}",
          *contents,
          "  #{indentation}#{close_token}#{comma}",
        ]
      end

      def contents
        operations.map do |operation|
          if operation.name == :change
            operation.child_operations.to_diff(
              indent_level: indent_level + 1,
              collection_prefix: build_item_prefix.call(operation),
              add_comma: operation.should_add_comma_after_displaying?,
            )
          else
            icon = ICONS.fetch(operation.name, " ")
            style_name = STYLES.fetch(operation.name, :normal)
            chunk = build_chunk(
              Helpers.inspect_object(operation.value, single_line: false),
              prefix: build_item_prefix.call(operation),
              icon: icon,
            )

            if operation.should_add_comma_after_displaying?
              chunk << ","
            end

            style_chunk(style_name, chunk)
          end
        end
      end

      def build_chunk(value, prefix:, icon:)
        lines =
          if value.is_a?(ValueInspection)
            flatten_tree(value.build_tree(level: 1), prefix: prefix)
          else
            [indentation(offset: 1) + prefix + value]
          end

        lines.map { |line| icon + " " + line }.join("\n")
      end

      def flatten_tree(tree, prefix:, root: true)
        tree.flat_map.with_index do |node, i|
          if node[:value].is_a?(::Array)
            flatten_tree(node[:value], prefix: prefix, root: false)
          else
            value = indentation(offset: node[:level])

            if root && prefix && node[:location] == "beginning"
              value << prefix
            end

            value << node[:value]

            if node[:location] == "middle" && !node[:last_item]
              value << ","
            end

            value
          end
        end
      end

      def style_chunk(style_name, chunk)
        chunk.
          split("\n").
          map { |line| Helpers.style(style_name, line) }.
          join("\n")
      end

      def indentation(offset: 0)
        " " * ((indent_level + offset) * 2)
      end

      def comma
        if add_comma
          ","
        else
          ""
        end
      end
    end
  end
end
