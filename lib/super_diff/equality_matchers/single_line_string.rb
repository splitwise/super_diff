module SuperDiff
  module EqualityMatchers
    class SingleLineString < Base
      def self.applies_to?(value)
        value.class == ::String
      end

      def fail
        <<~OUTPUT.strip
          Differing strings.

          #{
            Helpers.style(
              :deleted,
              "Expected: " +
              ObjectInspection.inspect(expected, single_line: true),
            )
          }
          #{
            Helpers.style(
              :inserted,
              "  Actual: " +
              ObjectInspection.inspect(actual, single_line: true),
            )
          }
        OUTPUT
      end
    end
  end
end
