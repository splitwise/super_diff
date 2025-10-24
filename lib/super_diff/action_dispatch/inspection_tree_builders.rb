# frozen_string_literal: true

module SuperDiff
  module ActionDispatch
    module InspectionTreeBuilders
      autoload(
        :Request,
        'super_diff/action_dispatch/inspection_tree_builders/request'
      )
    end
  end
end
