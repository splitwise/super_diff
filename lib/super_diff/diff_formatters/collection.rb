require_relative "../helpers"

module SuperDiff
  module DiffFormatters
    class Collection
      ICONS = { delete: "-", insert: "+" }
      STYLES = { insert: :inserted, delete: :deleted, noop: :normal }

      def self.call(
        open_token:,
        close_token:,
        operations:,
        indent:,
        &diff_line_for
      )
        new(
          open_token: open_token,
          close_token: close_token,
          operations: operations,
          indent: indent,
          &diff_line_for
        ).call
      end

      def initialize(
        open_token:,
        close_token:,
        operations:,
        indent:,
        &diff_line_for
      )
        @open_token = open_token
        @close_token = close_token
        @operations = operations
        @indent = indent
        @diff_line_for = diff_line_for
      end

      def call
        ["  #{open_token}", *contents, "  #{close_token}"].join("\n")
      end

      private

      attr_reader :open_token, :close_token, :operations, :indent,
        :diff_line_for

      def contents
        operations.map do |op|
          index = op.index
          collection = op.collection

          icon = ICONS.fetch(op.name, " ")
          style_name = STYLES.fetch(op.name, :normal)
          chunk = build_chunk(
            diff_line_for.(op),
            indent: indent,
            icon: icon
          )

          if index < collection.length - 1
            chunk << ","
          end

          style_chunk(style_name, chunk)
        end
      end

      def build_chunk(text, indent:, icon:)
        text
          .split("\n")
          .map { |line| icon + (" " * (indent - 1)) + line }
          .join("\n")
      end

      def style_chunk(style_name, chunk)
        chunk
          .split("\n")
          .map { |line| Helpers.style(style_name, line) }
          .join("\n")
      end
    end
  end
end
