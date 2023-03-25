module SuperDiff
  module Csi
    class ColorizedDocument < Document
      def initialize(&block)
        @color_sequences_open_in_parent = []
        super
      end

      protected

      def colorize_block(colors, opts, &block)
        color_sequence = build_initial_color_sequence_from(colors, opts)

        add_part(Csi.reset_sequence) if color_sequences_open_in_parent.any?

        add_part(color_sequence)
        color_sequences_open_in_parent << color_sequence
        evaluate_block(&block)
        add_part(Csi.reset_sequence)

        color_sequence_to_reopen = color_sequences_open_in_parent.pop
        if color_sequences_open_in_parent.any?
          add_part(color_sequence_to_reopen)
        end
      end

      def colorize_inline(contents, colors, opts)
        color_sequence = build_initial_color_sequence_from(colors, opts)

        add_part(color_sequence)

        contents.each do |content|
          if content.is_a?(self.class)
            content.each do |part|
              add_part(Csi.reset_sequence) if part.is_a?(ColorSequenceBlock)

              add_part(part)

              add_part(color_sequence) if part.is_a?(ResetSequence)
            end
          else
            add_part(content)
          end
        end

        add_part(Csi.reset_sequence)
      end

      private

      attr_reader :color_sequences_open_in_parent

      def build_initial_color_sequence_from(colors, opts)
        ColorSequenceBlock
          .new(colors)
          .tap do |sequence|
            if opts[:fg]
              sequence << Color.resolve(opts[:fg], layer: :foreground)
            end

            if opts[:bg]
              sequence << Color.resolve(opts[:bg], layer: :background)
            end
          end
      end
    end
  end
end
