module SuperDiff
  module RSpec
    class MatcherTextTemplate
      MAX_LINE_LENGTH = 100

      def self.render(&block)
        new(&block).to_s
      end

      def initialize
        @tokens = []

        yield self if block_given?
      end

      def add_text(*args, &block)
        add_token(PlainText, *args, &block)
      end

      def add_text_in_color(*args, &block)
        add_token(ColorizedText, *args, &block)
      end

      def add_text_in_singleline_mode(*args, &block)
        add_token(PlainTextInSinglelineMode, *args, &block)
      end

      def add_text_in_multiline_mode(*args, &block)
        add_token(PlainTextInMultilineMode, *args, &block)
      end

      def add_list_in_color(*args, &block)
        add_token(ColorizedList, *args, &block)
      end

      def add_break(*args, &block)
        add_token(Break, *args, &block)
      end

      def insert(*args, &block)
        add_token(Insertion, *args, &block)
      end

      def length_of_first_paragraph
        Csi.decolorize(to_string_in_singleline_mode).split(/\n\n/).first.length
      end

      def to_s(as_single_line: nil)
        if length_of_first_paragraph > MAX_LINE_LENGTH ||
             as_single_line == false
          to_string_in_multiline_mode
        elsif length_of_first_paragraph <= MAX_LINE_LENGTH ||
              as_single_line == true
          to_string_in_singleline_mode
        end
      end

      def to_string_in_singleline_mode
        tokens.map(&:to_string_in_singleline_mode).join
      end

      def to_string_in_multiline_mode
        tokens.map(&:to_string_in_multiline_mode).join
      end

      private

      attr_reader :tokens

      def add_token(klass, *args, &block)
        tokens << klass.new(*args, &block)
      end

      class Base
        def to_string_in_singleline_mode
          raise NotImplementedError.new(
                  "#{self.class} must support #to_string_in_singleline_mode"
                )
        end

        def to_string_in_multiline_mode
          raise NotImplementedError.new(
                  "#{self.class} must support #to_string_in_multiline_mode"
                )
        end

        def length
          to_string_in_singleline_mode.length
        end
      end

      class Text < Base
        def initialize(immediate_value = nil, &block)
          @immediate_value = immediate_value
          @block = block
        end

        def to_string_in_singleline_mode
          to_s
        end

        def to_string_in_multiline_mode
          to_s
        end

        def to_s
          raise NotImplementedError.new("#{self.class} must support #to_s")
        end

        protected

        attr_reader :immediate_value, :block

        def evaluate
          if immediate_value && block
            raise ArgumentError.new(
                    "Cannot provide both immediate value and block"
                  )
          end

          immediate_value || block.call
        end

        def to_sentence(values)
          case values.length
          when 0
            ""
          when 1
            values[0]
          else
            # TODO: Use Oxford comma
            values[0..-2].join(", ") + " and #{values[-1]}"
          end
        end
      end

      class PlainText < Text
        def to_s
          evaluate.to_s
        end
      end

      class ColorizedText < Text
        def initialize(color, *args, &block)
          super(*args, &block)

          @color = color
        end

        def to_s
          colorizer.wrap(evaluate.to_s, color)
        end

        def length
          evaluate.to_s.length
        end

        private

        attr_reader :color

        def colorizer
          ::RSpec::Core::Formatters::ConsoleCodes
        end
      end

      class ColorizedList < Text
        def initialize(color, *args, &block)
          super(*args, &block)

          @color = color
        end

        def to_s
          to_sentence(colorized_values)
        end

        private

        attr_reader :color

        def colorized_values
          evaluate.map do |value|
            colorizer.wrap(
              ::RSpec::Support::ObjectFormatter.format(value),
              color
            )
          end
        end

        def colorizer
          ::RSpec::Core::Formatters::ConsoleCodes
        end
      end

      class PlainTextInSinglelineMode < Text
        def to_string_in_singleline_mode
          evaluate.to_s
        end

        def to_string_in_multiline_mode
          ""
        end
      end

      class PlainTextInMultilineMode < Text
        def to_string_in_singleline_mode
          ""
        end

        def to_string_in_multiline_mode
          evaluate.to_s
        end
      end

      class Break < Base
        def to_string_in_singleline_mode
          " "
        end

        def to_string_in_multiline_mode
          "\n"
        end
      end

      class Insertion < Text
        def to_string_in_singleline_mode
          evaluate.to_string_in_singleline_mode
        end

        def to_string_in_multiline_mode
          evaluate.to_string_in_multiline_mode
        end
      end
    end
  end
end
