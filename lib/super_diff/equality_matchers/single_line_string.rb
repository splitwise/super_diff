require_relative "base"

module SuperDiff
  module EqualityMatchers
    class SingleLineString < Base
      def fail
        <<~OUTPUT.strip
          Differing strings.

          #{style :deleted,  "Expected: #{inspect(expected)}"}
          #{style :inserted, "  Actual: #{inspect(actual)}"}
        OUTPUT
      end
    end
  end
end
