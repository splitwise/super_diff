# frozen_string_literal: true

module SuperDiff
  module RSpec
    module MatcherTextBuilders
      class RaiseError < Base
        protected

        def actual_phrase
          if actual == 'exception-free block'
            'Expected'
          else
            'Expected raised exception'
          end
        end
      end
    end
  end
end
