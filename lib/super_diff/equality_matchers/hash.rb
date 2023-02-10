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

      protected

      def diff
        Differs::Hash.call(expected, actual, indent_level: 0)
      end
    end
  end
end
