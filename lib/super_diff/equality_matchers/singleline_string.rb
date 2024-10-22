# frozen_string_literal: true

module SuperDiff
  module EqualityMatchers
    class SinglelineString < Base
      def self.applies_to?(value)
        value.instance_of?(::String)
      end

      def fail
        <<~OUTPUT.strip
            Differing strings.

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
        OUTPUT
      end
    end
  end
end
