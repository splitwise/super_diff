module SuperDiff
  module EqualityMatchers
    class Array < Base
      def self.applies_to?(value)
        value.class == ::Array
      end

      def fail
        <<~OUTPUT.strip
          Differing arrays.

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

      protected

      def diff
        Differs::Array.call(
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
