# frozen_string_literal: true

module SuperDiff
  module RSpec
    module MatcherTextBuilders
      class ContainExactly < Base
        protected

        def add_expected_value_to(template, expected)
          template.add_text ' '
          template.add_list_in_color(expected_color, expected)
        end
      end
    end
  end
end
