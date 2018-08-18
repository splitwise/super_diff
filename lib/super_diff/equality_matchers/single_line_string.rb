require_relative "base"

module SuperDiff
  module EqualityMatchers
    class SingleLineString < Base
      def fail
        <<~OUTPUT.strip
          Differing strings.

          #{
            Helpers.style(
              :deleted,
              "Expected: #{Helpers.inspect_object(expected)}"
            )
          }
          #{
            Helpers.style(
              :inserted,
              "  Actual: #{Helpers.inspect_object(actual)}"
            )
          }
        OUTPUT
      end
    end
  end
end
