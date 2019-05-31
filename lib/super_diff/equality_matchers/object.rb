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
        Differs::Object.call(
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
