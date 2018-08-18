require_relative "../differs/array"
require_relative "base"

module SuperDiff
  module EqualityMatchers
    class Array < Base
      def fail
        <<~OUTPUT.strip
          Differing arrays.

          #{Helpers.style :deleted,  "Expected: #{expected.inspect}"}
          #{Helpers.style :inserted, "  Actual: #{actual.inspect}"}

          Diff:

          #{diff}
        OUTPUT
      end

      protected

      def diff
        Differs::Array.call(expected, actual, indent: 4)
      end
    end
  end
end
