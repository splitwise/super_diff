module SuperDiff
  module EqualityMatchers
    class Object < Base
      def self.applies_to?(value)
        value.class == ::Object
      end

      def fail
        <<~OUTPUT.strip
          Differing objects.

          #{
            Helpers.style(
              :deleted,
              "Expected: " +
              ObjectInspection.inspect(expected, as_single_line: true),
            )
          }
          #{
            Helpers.style(
              :inserted,
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
        Differ.call(
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
