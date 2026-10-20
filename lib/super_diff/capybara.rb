# frozen_string_literal: true

require 'super_diff/capybara/inspection_tree_builders'

module SuperDiff
  module Capybara
    SuperDiff.configure do |config|
      config.prepend_extra_inspection_tree_builder_classes(
        InspectionTreeBuilders::Node
      )
    end
  end
end
