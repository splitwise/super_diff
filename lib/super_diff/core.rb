# frozen_string_literal: true

module SuperDiff
  module Core
    autoload :AbstractDiffer, 'super_diff/core/abstract_differ'
    autoload(
      :AbstractInspectionTreeBuilder,
      'super_diff/core/abstract_inspection_tree_builder'
    )
    autoload :AbstractOperationTree, 'super_diff/core/abstract_operation_tree'
    autoload(
      :AbstractOperationTreeBuilder,
      'super_diff/core/abstract_operation_tree_builder'
    )
    autoload(
      :AbstractOperationTreeFlattener,
      'super_diff/core/abstract_operation_tree_flattener'
    )
    autoload :BinaryOperation, 'super_diff/core/binary_operation'
    autoload(
      :ColorizedDocumentExtensions,
      'super_diff/core/colorized_document_extensions'
    )
    autoload :Configuration, 'super_diff/core/configuration'
    autoload :DifferDispatcher, 'super_diff/core/differ_dispatcher'
    autoload :GemVersion, 'super_diff/core/gem_version'
    autoload :Helpers, 'super_diff/core/helpers'
    autoload :ImplementationChecks, 'super_diff/core/implementation_checks'
    autoload :InspectionTree, 'super_diff/core/inspection_tree'
    autoload(
      :InspectionTreeBuilderDispatcher,
      'super_diff/core/inspection_tree_builder_dispatcher'
    )
    autoload :InspectionTreeNodes, 'super_diff/core/inspection_tree_nodes'
    autoload :Line, 'super_diff/core/line'
    autoload(
      :OperationTreeBuilderDispatcher,
      'super_diff/core/operation_tree_builder_dispatcher'
    )
    autoload(
      :NoDifferAvailableError,
      'super_diff/core/no_differ_available_error'
    )
    autoload(
      :NoInspectionTreeAvailableError,
      'super_diff/core/no_inspection_tree_builder_available_error'
    )
    autoload(
      :NoOperationTreeBuilderAvailableError,
      'super_diff/core/no_operation_tree_builder_available_error'
    )
    autoload(
      :NoOperationTreeAvailableError,
      'super_diff/core/no_operation_tree_available_error'
    )
    autoload :OperationTreeFinder, 'super_diff/core/operation_tree_finder'
    autoload(
      :PrefixForNextInspectionTreeNode,
      'super_diff/core/prefix_for_next_inspection_tree_node'
    )
    autoload(
      :PreludeForNextInspectionTreeNode,
      'super_diff/core/prelude_for_next_inspection_tree_node'
    )
    autoload :RecursionGuard, 'super_diff/core/recursion_guard'
    autoload :TieredLines, 'super_diff/core/tiered_lines'
    autoload :TieredLinesElider, 'super_diff/core/tiered_lines_elider'
    autoload :TieredLinesFormatter, 'super_diff/core/tiered_lines_formatter'
    autoload :UnaryOperation, 'super_diff/core/unary_operation'
  end
end
