require_relative "../differs/hash"
require_relative "base"

module SuperDiff
  module EqualityMatchers
    class Hash < Base
      def fail
        <<~OUTPUT.strip
          Differing hashes.

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

      protected

      def diff
        Differs::Hash.call(expected, actual, indent: 4)
      end
    end
  end
end
