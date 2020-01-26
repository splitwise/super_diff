module SuperDiff
  module Csi
    class Document
      include Enumerable

      def initialize(&block)
        @parts = []
        @indentation_stack = []

        if block
          apply(&block)
        end
      end

      def +(other)
        to_s + other.to_s
      end

      def each(&block)
        parts.each(&block)
      end

      def bold(*args, **opts, &block)
        colorize(BoldSequence.new, *args, **opts, &block)
      end

      def underline(*args, **opts, &block)
        colorize(UnderlineSequence.new, *args, **opts, &block)
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

      def text(*contents, **, &block)
        if block
          apply(&block)
        elsif contents.any?
          contents.each do |part|
            add_part(part)
          end
        else
          raise ArgumentError.new(
            "Must have something to add to the document!",
          )
        end
      end
      alias_method :plain, :text

      def line(*contents, indent_by: 0, &block)
        indent(by: indent_by) do
          # if block
            # binding.pry
          # end

          add_part(indentation_stack.join)

          if block
            apply(&block)
          elsif contents.any?
            text(*contents)
          else
            raise ArgumentError.new(
              "Must have something to add to the document!",
            )
          end
        end

        add_part("\n")
      end
      alias_method :add_line, :line

      def newline
        add_part("\n")
      end

      def indent(by:, &block)
        # TODO: This won't work if using `text` manually to add lines
        indentation_stack << (by.is_a?(String) ? by : " " * by)
        apply(&block)
        indentation_stack.pop
      end

      def apply(&block)
        if block.arity > 0
          block.call(self)
        else
          instance_eval(&block)
        end
      end

      def method_missing(name, *args, **opts, &block)
        request = derive_request_from(name)

        if request
          request.resolve(self, args, opts, &block)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        request = derive_request_from(name)
        !request.nil? || super
      end

      def to_s
        parts.map(&:to_s).join.rstrip
      end

      protected

      attr_reader :parts, :indentation_stack

      def derive_request_from(name)
        match = name.to_s.match(/\A(.+)_line\Z/)

        if match
          color_name = match[1].to_sym

          if respond_to?(color_name)
            MethodRequest.new(name: color_name, line: true)
          elsif Csi::Color.exists?(color_name)
            ColorRequest.new(name: color_name, line: true)
          end
        elsif Csi::Color.exists?(name.to_sym)
          ColorRequest.new(name: name.to_sym, line: false)
        else
          nil
        end
      end

      def add_part(part)
        parts.push(part)
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

      class MethodRequest < Request
        def resolve(doc, args, opts, &block)
          doc.public_send(wrapper, **opts) do |d|
            d.public_send(name, *args, &block)
          end
        end
      end

      class ColorRequest < Request
        def resolve(doc, args, opts, &block)
          doc.public_send(wrapper, **opts) do |d|
            d.colorize(*args, fg: name, &block)
          end
        end
      end
    end
  end
end
