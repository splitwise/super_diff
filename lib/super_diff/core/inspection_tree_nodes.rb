# frozen_string_literal: true

module SuperDiff
  module Core
    module InspectionTreeNodes
      autoload(
        :AsLinesWhenRenderingToLines,
        'super_diff/core/inspection_tree_nodes/as_lines_when_rendering_to_lines'
      )
      autoload(
        :AsPrefixWhenRenderingToLines,
        'super_diff/core/inspection_tree_nodes/as_prefix_when_rendering_to_lines'
      )
      autoload(
        :AsPreludeWhenRenderingToLines,
        'super_diff/core/inspection_tree_nodes/as_prelude_when_rendering_to_lines'
      )
      autoload(
        :AsSingleLine,
        'super_diff/core/inspection_tree_nodes/as_single_line'
      )
      autoload :Base, 'super_diff/core/inspection_tree_nodes/base'
      autoload :Inspection, 'super_diff/core/inspection_tree_nodes/inspection'
      autoload :Nesting, 'super_diff/core/inspection_tree_nodes/nesting'
      autoload :OnlyWhen, 'super_diff/core/inspection_tree_nodes/only_when'
      autoload :Text, 'super_diff/core/inspection_tree_nodes/text'
      autoload :WhenEmpty, 'super_diff/core/inspection_tree_nodes/when_empty'
      autoload(
        :WhenNonEmpty,
        'super_diff/core/inspection_tree_nodes/when_non_empty'
      )
      autoload(
        :WhenRenderingToLines,
        'super_diff/core/inspection_tree_nodes/when_rendering_to_lines'
      )
      autoload(
        :WhenRenderingToString,
        'super_diff/core/inspection_tree_nodes/when_rendering_to_string'
      )

      def self.registry
        @registry ||= [
          AsLinesWhenRenderingToLines,
          AsPrefixWhenRenderingToLines,
          AsPreludeWhenRenderingToLines,
          AsSingleLine,
          Inspection,
          Nesting,
          OnlyWhen,
          Text,
          WhenRenderingToLines,
          WhenRenderingToString
        ]
      end
    end
  end
end
