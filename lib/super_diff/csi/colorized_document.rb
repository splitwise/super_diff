module SuperDiff
  module Csi
    class ColorizedDocument
      def self.colorize(*args, **opts, &block)
        if block
          new(&block)
        else
          new { colorize(*args, **opts) }
        end
      end

      include Enumerable

      def initialize(&block)
        @parts = []
        @color_sequences_open_in_parent = []
        @indentation_stack = []

        evaluate_block(&block)
      end

      def each(&block)
        parts.each(&block)
      end

      def text(*contents, **, &block)
        if block
          evaluate_block(&block)
        elsif contents.any?
          parts.push(*contents)
        else
          raise ArgumentError.new(
            "Must have something to add to the document!",
          )
        end
      end

      def line(*contents, indent_by: 0, &block)
        indent(by: indent_by) do
          parts << indentation_stack.join

          if block
            evaluate_block(&block)
          elsif contents.any?
            text(*contents)
          else
            raise ArgumentError.new(
              "Must have something to add to the document!",
            )
          end
        end

        parts << "\n"
      end

      def newline
        parts << "\n"
      end

      def indent(by:, &block)
        # TODO: This won't work if using `text` manually to add lines
        indentation_stack << (by.is_a?(String) ? by : " " * by)
        evaluate_block(&block)
        indentation_stack.pop
      end

      def colorize(*args, **opts, &block)
        contents, colors = args.partition do |arg|
          arg.is_a?(String) || arg.is_a?(self.class)
        end

        if colors[0].is_a?(Symbol)
          if colors[0] == :colorize
            raise ArgumentError, "#colorize can't call itself!"
          else
            public_send(colors[0], *contents, *colors[1..-1], **opts, &block)
          end
        elsif !block && colors.empty? && opts.empty?
          text(*contents)
        elsif block
          colorize_block(colors, opts, &block)
        elsif contents.any?
          colorize_inline(contents, colors, opts)
        else
          raise ArgumentError, "Must have something to colorize!"
        end
      end
      alias_method :colored, :colorize

      def method_missing(name, *args, **opts, &block)
        request = derive_color_request_from(name)

        if request
          request.resolve(self, args, opts, &block)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        request = derive_color_request_from(name)
        !request.nil? || super
      end

      def to_s
        parts.map(&:to_s).join.rstrip
      end

      private

      attr_reader :parts, :color_sequences_open_in_parent, :indentation_stack

      def derive_color_request_from(name)
        match = name.to_s.match(/\A(.+)_line\Z/)

        if match
          if respond_to?(match[1].to_sym)
            return MethodRequest.new(name: match[1].to_sym, line: true)
          elsif Csi::Color.exists?(match[1].to_sym)
            return ColorRequest.new(name: match[1].to_sym, line: true)
          end
        elsif Csi::Color.exists?(name.to_sym)
          return ColorRequest.new(name: name.to_sym, line: false)
        end
      end

      def colorize_block(colors, opts, &block)
        color_sequence = build_initial_color_sequence_from(colors, opts)

        if color_sequences_open_in_parent.any?
          parts << Csi.reset_sequence
        end

        parts << color_sequence
        color_sequences_open_in_parent << color_sequence
        evaluate_block(&block)
        parts << Csi.reset_sequence

        color_sequence_to_reopen = color_sequences_open_in_parent.pop
        if color_sequences_open_in_parent.any?
          parts << color_sequence_to_reopen
        end
      end

      def colorize_inline(contents, colors, opts)
        color_sequence = build_initial_color_sequence_from(colors, opts)

        parts << color_sequence

        contents.each do |content|
          if content.is_a?(self.class)
            content.each do |part|
              if part.is_a?(ColorSequence)
                parts << Csi.reset_sequence
              end

              parts << part

              if part.is_a?(Csi::ResetSequence)
                parts << color_sequence
              end
            end
          else
            parts << content
          end
        end

        parts << Csi.reset_sequence
      end

      def build_initial_color_sequence_from(colors, opts)
        ColorSequence.new(colors).tap do |sequence|
          if opts[:fg]
            sequence << Csi::Color.resolve(opts[:fg], layer: :foreground)
          end

          if opts[:bg]
            sequence << Csi::Color.resolve(opts[:bg], layer: :background)
          end
        end
      end

      def evaluate_block(&block)
        if block.arity > 0
          block.call(self)
        else
          instance_eval(&block)
        end
      end

      class Request
        def initialize(name:, line:)
          @name = name
          @line = line
        end

        protected

        attr_reader :name

        def for_line?
          @line
        end

        def wrapper
          if for_line?
            :line
          else
            :text
          end
        end
      end

      class ColorRequest < Request
        def resolve(doc, args, opts, &block)
          doc.public_send(wrapper) do |d|
            d.colorize(*args, **opts, fg: name, &block)
          end
        end
      end

      class MethodRequest < Request
        def resolve(doc, args, opts, &block)
          doc.public_send(wrapper) do |d|
            d.public_send(name, *args, **opts, &block)
          end
        end
      end

      class ColorSequence
        include Enumerable

        def initialize(colors = [])
          @colors = colors
        end

        def each(&block)
          colors.each(&block)
        end

        def push(color)
          colors.push(color)
        end
        alias_method :<<, :push

        def to_s
          colors.map(&:to_s).join
        end

        private

        attr_reader :colors
      end
    end
  end
end
