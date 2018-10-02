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
              "Expected: #{Helpers.inspect_object(expected)}",
            )
          }
          #{
            Helpers.style(
              :inserted,
              "  Actual: #{Helpers.inspect_object(actual)}",
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
