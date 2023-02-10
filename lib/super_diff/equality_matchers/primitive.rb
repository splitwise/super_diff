module SuperDiff
  module EqualityMatchers
    class Primitive < Base
      def self.applies_to?(value)
        # TODO: Test all of these options
        SuperDiff.primitive?(value)
      end

      def fail
        <<~OUTPUT.strip
          Differing #{Helpers.plural_type_for(actual)}.

          #{
          Helpers.style(
            :expected,
            "Expected: " + SuperDiff.inspect_object(expected, as_lines: false)
          )
        }
          #{
          Helpers.style(
            :actual,
            "  Actual: " + SuperDiff.inspect_object(actual, as_lines: false)
          )
        }
        OUTPUT
      end
    end
  end
end
