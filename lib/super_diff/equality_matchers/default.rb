# frozen_string_literal: true

module SuperDiff
  module EqualityMatchers
    class Default < Base
      def self.applies_to?(_value)
        true
      end

      def fail
        <<~OUTPUT.strip
          Differing objects.

          #{expected_line}
          #{actual_line}
          #{diff_section}
        OUTPUT
      end

      protected

      def expected_line
        Core::Helpers.style(
          :expected,
          "Expected: #{SuperDiff.inspect_object(expected, as_lines: false)}"
        )
      end

      def actual_line
        Core::Helpers.style(
          :actual,
          "  Actual: #{SuperDiff.inspect_object(actual, as_lines: false)}"
        )
      end

      def diff_section
        if diff.empty?
          ''
        else
          <<~SECTION

            Diff:

            #{diff}
          SECTION
        end
      end

      def diff
        SuperDiff.diff(
          expected,
          actual,
          indent_level: 0,
          raise_if_nothing_applies: false
        )
      end
    end
  end
end
