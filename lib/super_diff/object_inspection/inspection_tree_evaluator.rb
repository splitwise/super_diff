module SuperDiff
  module ObjectInspection
    class InspectionTreeEvaluator
      def self.call(
        tree,
        object,
        single_line:,
        indent_level: 0,
        overall_prefix: nil,
        line_prefix: nil
      )
        evaluator = new(
          tree,
          object,
          single_line: single_line,
          indent_level: indent_level,
          overall_prefix: overall_prefix,
          line_prefix: line_prefix,
        )
        evaluator.call
      end

      def initialize(
        tree,
        object,
        single_line:,
        indent_level: 0,
        overall_prefix: nil,
        line_prefix: nil
      )
        @tree = tree
        @object = object
        @single_line = single_line
        @indent_level = indent_level
        @overall_prefix = overall_prefix
        @line_prefix = line_prefix
      end

      def call
        transformed_tree.evaluate(
          object,
          single_line: single_line,
          indent_level: indent_level,
        )
      end

      private

      attr_reader :tree, :object, :single_line, :indent_level, :overall_prefix,
        :line_prefix

      def transformed_tree
        @_transformed_tree ||= transform_tree
      end

      def transform_tree
        InspectionTree.new.tap do |transformed_tree|
          if overall_prefix
            transformed_tree.add_text(overall_prefix)
          end

          if line_prefix
            transformed_tree.add_text(line_prefix)
            transformed_tree.will_prepend_each_line_with(line_prefix)
          end

          transformed_tree.apply_tree(tree)
        end
      end
    end
  end
end
