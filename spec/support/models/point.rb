# frozen_string_literal: true

if defined?(Data)
  module SuperDiff
    module Test
      Point = Data.define(:x, :y)
    end
  end
end
