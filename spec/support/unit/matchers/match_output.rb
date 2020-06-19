module SuperDiff
  module UnitTests
    def match_output(expected_output)
      MatchOutputMatcher.new(expected_output)
    end

    class MatchOutputMatcher
      extend AttrExtras.mixin

      pattr_initialize :expected_output
      attr_private :actual_output

      def matches?(actual_output)
        @actual_output = actual_output
        actual_output == expected_output
      end

      def failure_message
        message =
          "Expected colored output to be printed, but got a mismatch.\n\n" +
          "Expected output:\n\n" +
          SuperDiff::Test::OutputHelpers.bookended(expected_output) +
          "\n" +
          "Actual output:\n\n" +
          SuperDiff::Test::OutputHelpers.bookended(actual_output)

        if ["1", "true"].include?(ENV["SHOW_DIFF"])
          ::RSpec::Matchers::ExpectedsForMultipleDiffs.
            from(expected_output).
            message_with_diff(
              message,
              ::RSpec::Expectations.differ,
              actual_output,
            )
        else
          message
        end
      end
    end
  end
end
