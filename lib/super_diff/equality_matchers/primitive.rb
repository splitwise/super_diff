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
        OUTPUT
      end
    end
  end
end
