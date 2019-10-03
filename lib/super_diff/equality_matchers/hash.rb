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
              :alpha,
              "Expected: " +
              ObjectInspection.inspect(expected, as_single_line: true),
            )
          }
          #{
            Helpers.style(
              :beta,
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
        Differs::Hash.call(
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
