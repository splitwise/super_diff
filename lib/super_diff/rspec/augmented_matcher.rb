module SuperDiff
  module RSpec
    module AugmentedMatcher
      # Update to use expected_for_description instead of @expected
      def description
        failure_message_builder.matcher_description
      end

      # Colorize the 'actual' value
      def failure_message
        build_failure_message(negated: false)
      end

      # Colorize the 'actual' value
      def failure_message_when_negated
        build_failure_message(negated: true)
      end

      # Always be diffable (we have the logic of whether to show a diff or not
      # in SuperDiff::RSpec::Differ)
      def diffable?
        true
      end

      protected

      def build_failure_message(negated:)
        failure_message_template_builder.call(negated: negated)
      end

      def actual_for_failure_message
        description_of(actual)
      end

      def expected_for_failure_message
        description_of(expected)
      end

      def failure_message_template_builder
        @_failure_message_template_builder ||=
          failure_message_template_builder_class.new(
            actual: actual_for_failure_message,
            expected: expected_for_failure_message,
            description_as_phrase: description_as_phrase,
          )
      end

      def failure_message_template_builder_class
        FailureMessageBuilders::Base
      end

      private

      def description_as_phrase
        ::RSpec::Matchers::EnglishPhrasing.split_words(self.class.matcher_name)
      end

      def readable_list_of(things)
        ::RSpec::Matchers::EnglishPhrasing.list(things)
      end

      def matchers
        Object.new.tap do |object|
          object.singleton_class.class_eval do
            include ::RSpec::Matchers
          end
        end
      end

      def colorizer
        ::RSpec::Core::Formatters::ConsoleCodes
      end
    end
  end
end
