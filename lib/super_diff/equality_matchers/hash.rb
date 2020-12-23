module SuperDiff
  module EqualityMatchers
    class Hash < Base
      def self.applies_to?(value)
        value.class == ::Hash
      end

      def fail
        <<~OUTPUT.strip
          Differing hashes.

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

          Diff:

          #{diff}
        OUTPUT
      end

      protected

      def diff
        Differs::Hash.call(expected, actual, indent_level: 0)
      end
    end
  end
end
