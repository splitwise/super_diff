# frozen_string_literal: true

module SuperDiff
  module EqualityMatchers
    class Hash < Base
      def self.applies_to?(value)
        value.instance_of?(::Hash)
      end

      def fail
        <<~OUTPUT.strip
            Differing hashes.

            #{
            Core::Helpers.style(
              :expected,
              "Expected: #{SuperDiff.inspect_object(expected, as_lines: false)}"
            )
          }
            #{
            Core::Helpers.style(
              :actual,
              "  Actual: #{SuperDiff.inspect_object(actual, as_lines: false)}"
            )
          }

            Diff:

            #{diff}
        OUTPUT
      end

      protected

      def diff
        Basic::Differs::Hash.call(expected, actual, indent_level: 0)
      end
    end
  end
end
