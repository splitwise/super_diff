# frozen_string_literal: true

module SuperDiff
  module IntegrationTests
    def fail_with_indented_multiline_failure_message
      FailWithIndentedMultilineFailureMessageMatcher.new
    end

    def fail_with_paragraphed_failure_message
      FailWithParagraphedFailureMessageMatcher.new
    end

    def fail_with_non_indented_multiline_failure_message
      FailWithNonIndentedMultilineFailureMessageMatcher.new
    end

    def fail_with_singleline_failure_message
      FailWithSinglelineFailureMessageMatcher.new
    end

    def pass_with_indented_multiline_failure_message
      PassWithIndentedMultilineFailureMessageMatcher.new
    end

    def pass_with_paragraphed_failure_message
      PassWithParagraphedFailureMessageMatcher.new
    end

    def pass_with_non_indented_multiline_failure_message
      PassWithNonIndentedMultilineFailureMessageMatcher.new
    end

    def pass_with_singleline_failure_message
      PassWithSinglelineFailureMessageMatcher.new
    end

    RSpec::Matchers.define :failing_custom_matcher_from_dsl do |value|
      match { false }

      description do
        "custom matcher defined via the DSL with value #{value.inspect}"
      end
    end

    def failing_custom_matcher_from_scratch(value)
      FailingCustomMatcherFromScratch.new(value)
    end

    class FailingCustomMatcherFromScratch
      def initialize(value)
        @value = value
      end

      def matches?(_)
        false
      end

      def description
        "custom matcher defined from scratch with value #{value.inspect}"
      end

      def failure_message
        'Expected custom matcher not to fail, but did'
      end

      private

      attr_reader :value
    end

    class FailWithIndentedMultilineFailureMessageMatcher
      def matches?(_)
        false
      end

      def failure_message
        <<~MESSAGE
          This is a message that spans multiple lines.
          Here is the next line.
            This part is indented, for whatever reason. It just kinda keeps
            going until we finish saying whatever it is we want to say.
        MESSAGE
      end
    end

    class FailWithParagraphedFailureMessageMatcher
      def matches?(_)
        false
      end

      def failure_message
        <<~MESSAGE
          This is a message that spans multiple paragraphs.

          Here is the next paragraph.
        MESSAGE
      end
    end

    class FailWithNonIndentedMultilineFailureMessageMatcher
      def matches?(_)
        false
      end

      def failure_message
        <<~MESSAGE
          This is a message that spans multiple lines.
          Here is the next line.
        MESSAGE
      end
    end

    class FailWithSinglelineFailureMessageMatcher
      def matches?(_)
        false
      end

      def failure_message
        <<~MESSAGE
          This is a message that spans only one line.
        MESSAGE
      end
    end

    class PassWithIndentedMultilineFailureMessageMatcher
      def does_not_match?(_)
        false
      end

      def failure_message_when_negated
        <<~MESSAGE
          This is a message that spans multiple lines.
          Here is the next line.
            This part is indented, for whatever reason. It just kinda keeps
            going until we finish saying whatever it is we want to say.
        MESSAGE
      end
    end

    class PassWithParagraphedFailureMessageMatcher
      def does_not_match?(_)
        false
      end

      def failure_message_when_negated
        <<~MESSAGE
          This is a message that spans multiple paragraphs.

          Here is the next paragraph.
        MESSAGE
      end
    end

    class PassWithNonIndentedMultilineFailureMessageMatcher
      def does_not_match?(_)
        false
      end

      def failure_message_when_negated
        <<~MESSAGE
          This is a message that spans multiple lines.
          Here is the next line.
        MESSAGE
      end
    end

    class PassWithSinglelineFailureMessageMatcher
      def does_not_match?(_)
        false
      end

      def failure_message_when_negated
        <<~MESSAGE
          This is a message that spans only one line.
        MESSAGE
      end
    end
  end
end
