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
              "Expected: #{Helpers.inspect_object(expected)}"
            )
          }
          #{
            Helpers.style(
              :inserted,
              "  Actual: #{Helpers.inspect_object(actual)}"
            )
          }

          Diff:

          #{diff}
        OUTPUT
      end

      private

      def diff
        DiffFormatters::MultiLineString.call(operations, indent_level: 0)
      end

      def operations
        OperationalSequencers::MultiLineString.call(
          expected: expected,
          actual: actual
        )
      end
    end
  end
end
