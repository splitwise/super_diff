module SuperDiff
  module EqualityMatchers
    class Primitive < Base
      def self.applies_to?(value)
        value.is_a?(Symbol) ||
          value.is_a?(Numeric) ||
          # TODO: Test this
          value == true ||
          value == false
      end

      def fail
        <<~OUTPUT.strip
          Differing #{Helpers.plural_type_for(actual)}.

          #{
            Helpers.style(
              :expected,
              "Expected: " +
              ObjectInspection.inspect(expected, as_single_line: true),
            )
          }
          #{
            Helpers.style(
              :actual,
              "  Actual: " +
              ObjectInspection.inspect(actual, as_single_line: true),
            )
          }
        OUTPUT
      end
    end
  end
end
