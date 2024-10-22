# frozen_string_literal: true

module SuperDiff
  module RSpec
    module MatcherTextBuilders
      class Match < Base
        def initialize(expected_captures:, **rest)
          super(**rest)
          @expected_captures = expected_captures
        end

        def add_extra
          return unless expected_captures

          template.add_text 'with captures '
          template.add_text_in_color :blue, description_of(expected_captures)
        end

        private

        attr_reader :expected_captures
      end
    end
  end
end
