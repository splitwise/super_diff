module SuperDiff
  module EqualityMatchers
    class SinglelineString < Base
      def self.applies_to?(value)
        value.class == ::String
      end

      def fail
        <<~OUTPUT.strip
          Differing strings.

          #{
            Helpers.style(
              :expected,
              "Expected: " +
              ObjectInspection.inspect(expected, as_single_line: true),
            )
          }
          #{
            Helpers.style(
              :actual,
              "  Actual: " +
              ObjectInspection.inspect(actual, as_single_line: true),
            )
          }
        OUTPUT
      end
    end
  end
end
