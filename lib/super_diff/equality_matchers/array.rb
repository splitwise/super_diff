# frozen_string_literal: true

module SuperDiff
  module EqualityMatchers
    class Array < Base
      def self.applies_to?(value)
        value.instance_of?(::Array)
      end

      def fail
        <<~OUTPUT.strip
            Differing arrays.

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
        Basic::Differs::Array.call(expected, actual, indent_level: 0)
      end
    end
  end
end
