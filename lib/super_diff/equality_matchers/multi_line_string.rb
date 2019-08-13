module SuperDiff
  module EqualityMatchers
    class MultiLineString < Base
      def self.applies_to?(value)
        value.is_a?(::String) && value.include?("\n")
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

          Diff:

          #{diff}
        OUTPUT
      end

      private

      def diff
        Differs::MultiLineString.call(
          expected,
          actual,
          indent_level: 0,
          extra_operational_sequencer_classes: extra_operational_sequencer_classes,
          extra_diff_formatter_classes: extra_diff_formatter_classes,
        )
      end
    end
  end
end
