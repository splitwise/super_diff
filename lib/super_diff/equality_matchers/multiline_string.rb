module SuperDiff
  module EqualityMatchers
    class MultilineString < Base
      def self.applies_to?(value)
        value.is_a?(::String) && value.include?("\n")
      end

      def fail
        <<~OUTPUT.strip
          Differing strings.

          #{
          # TODO: This whole thing should not be red or green, just the values
          Helpers.style(
            :expected,
            "Expected: " + SuperDiff.inspect_object(expected, as_lines: false)
          )
        }
          #{
          Helpers.style(
            :actual,
            "  Actual: " + SuperDiff.inspect_object(actual, as_lines: false)
          )
        }

          Diff:

          #{diff}
        OUTPUT
      end

      private

      def diff
        Differs::MultilineString.call(expected, actual, indent_level: 0)
      end
    end
  end
end
