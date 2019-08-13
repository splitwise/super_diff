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
              "Expected: #{Helpers.inspect_object(expected)}",
            )
          }
          #{
            Helpers.style(
              :inserted,
              "  Actual: #{Helpers.inspect_object(actual)}",
            )
          }
        OUTPUT
      end
    end
  end
end
