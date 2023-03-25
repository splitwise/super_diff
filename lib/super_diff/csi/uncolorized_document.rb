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
            content.each { |part| add_part(part) }
          else
            add_part(content)
          end
        end
      end

      def add_part(part)
        super if !part.is_a?(ResetSequence) && !part.is_a?(ColorSequenceBlock)
      end
    end
  end
end
