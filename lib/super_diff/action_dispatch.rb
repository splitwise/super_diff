# frozen_string_literal: true

require 'super_diff/action_dispatch/inspection_tree_builders'

module SuperDiff
  module ActionDispatch
    SuperDiff.configure do |config|
      config.prepend_extra_inspection_tree_builder_classes(
        InspectionTreeBuilders::Request
      )
    end
  end
end
