module SuperDiff
  module Csi
    class UncolorizedDocument < Document
      protected

      def colorize_block(*, &block)
        evaluate_block(&block)
      end

      def colorize_inline(contents, *)
        contents.each do |content|
          if content.is_a?(self.class)
            content.each do |part|
              add_part(part)
            end
          else
            add_part(content)
          end
        end
      end

      def add_part(part)
        if !part.is_a?(ResetSequence) && !part.is_a?(ColorSequenceBlock)
          super
        end
      end
    end
  end
end
