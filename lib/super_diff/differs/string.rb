require_relative "multi_line_string"
require_relative "single_line_string"

module SuperDiff
  module Differs
    module String
      def self.call(expected, actual)
        if expected.include?("\n") || actual.include?("\n")
          MultiLineString.call(expected, actual)
        else
          SingleLineString.call(expected, actual)
        end
      end
    end
  end
end
