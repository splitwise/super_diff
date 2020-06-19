module SuperDiff
  class TieredLinesFormatter
    extend AttrExtras.mixin

    method_object :tiered_lines

    def call
      colorized_document.to_s.chomp
    end

    private

    def colorized_document
      SuperDiff::Helpers.style do |doc|
        formattable_lines.each do |formattable_line|
          doc.public_send(
            "#{formattable_line.color}_line",
            formattable_line.content,
          )
        end
      end
    end

    def formattable_lines
      tiered_lines.map { |line| FormattableLine.new(line) }
    end

    class FormattableLine
      extend AttrExtras.mixin

      INDENTATION_UNIT = "  ".freeze
      ICONS = { delete: "-", insert: "+", elision: " ", noop: " " }.freeze
      COLORS = {
        delete: :expected,
        insert: :actual,
        elision: :elision_marker,
        noop: :plain,
      }.freeze

      pattr_initialize :line

      def content
        icon + " " + indentation + line.prefix + line.value + possible_comma
      end

      def color
        COLORS.fetch(line.type) do
          raise(
            KeyError,
            "Couldn't find color for line type #{line.type.inspect}!",
          )
        end
      end

      private

      def icon
        ICONS.fetch(line.type) do
          raise(
            KeyError,
            "Couldn't find icon for line type #{line.type.inspect}!",
          )
        end
      end

      def indentation
        INDENTATION_UNIT * line.indentation_level
      end

      def possible_comma
        if line.add_comma?
          ","
        else
          ""
        end
      end
    end
  end
end
