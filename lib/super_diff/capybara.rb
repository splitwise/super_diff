# frozen_string_literal: true

require 'super_diff/capybara/differs'
require 'super_diff/capybara/inspection_tree_builders'

module SuperDiff
  module Capybara
    def self.applies_to?(*values)
      values.all? do |value|
        value.is_a?(::Capybara::Node::Base) ||
          value.is_a?(::Capybara::Driver::Node)
      end
    end

    SuperDiff.configure do |config|
      config.prepend_extra_differ_classes(Differs::Node)
      config.prepend_extra_inspection_tree_builder_classes(
        InspectionTreeBuilders::Node
      )
    end
  end
end
