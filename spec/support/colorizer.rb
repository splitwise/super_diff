# frozen_string_literal: true

module SuperDiff
  module Tests
    module Colorizer
      def self.call(...)
        SuperDiff::Helpers.style(...)
      end
    end
  end
end
