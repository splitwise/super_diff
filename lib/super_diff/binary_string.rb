# frozen_string_literal: true

require 'super_diff/binary_string/differs'
require 'super_diff/binary_string/inspection_tree_builders'
require 'super_diff/binary_string/operation_trees'
require 'super_diff/binary_string/operation_tree_builders'
require 'super_diff/binary_string/operation_tree_flatteners'

module SuperDiff
  module BinaryString
    def self.applies_to?(*values)
      values.all? { |value| value.is_a?(::String) && value.encoding == Encoding::ASCII_8BIT }
    end

    SuperDiff.configure do |config|
      config.prepend_extra_differ_classes(Differs::BinaryString)
      config.prepend_extra_operation_tree_builder_classes(
        OperationTreeBuilders::BinaryString
      )
      config.prepend_extra_operation_tree_classes(
        OperationTrees::BinaryString
      )
      config.prepend_extra_inspection_tree_builder_classes(
        InspectionTreeBuilders::BinaryString
      )
    end
  end
end
