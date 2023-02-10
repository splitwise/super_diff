module SuperDiff
  module RSpec
    module AugmentedMatcher
      # Update to use expected_for_description instead of @expected
      # TODO: Test
      def description
        matcher_text_builder.matcher_description
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
        matcher_text_builder.call(negated: negated)
      end

      def matcher_text_builder
        @_matcher_text_builder ||=
          matcher_text_builder_class.new(**matcher_text_builder_args)
      end

      def matcher_text_builder_class
        RSpec::MatcherTextBuilders::Base
      end

      def matcher_text_builder_args
        {
          actual: actual_for_matcher_text,
          expected_for_failure_message: expected_for_failure_message,
          expected_for_description: expected_for_description,
          expected_action_for_failure_message:
            expected_action_for_failure_message,
          expected_action_for_description: expected_action_for_description
        }
      end

      def actual_for_matcher_text
        description_of(actual)
      end

      def expected_for_matcher_text
        description_of(expected)
      end

      def expected_for_failure_message
        expected_for_matcher_text
      end

      def expected_for_description
        expected_for_matcher_text
      end

      private

      def expected_action_for_matcher_text
        ::RSpec::Matchers::EnglishPhrasing.split_words(self.class.matcher_name)
      end

      def expected_action_for_failure_message
        expected_action_for_matcher_text
      end

      def expected_action_for_description
        expected_action_for_matcher_text
      end

      def readable_list_of(things)
        ::RSpec::Matchers::EnglishPhrasing.list(things)
      end

      def matchers
        Object.new.tap do |object|
          object.singleton_class.class_eval { include ::RSpec::Matchers }
        end
      end

      def colorizer
        ::RSpec::Core::Formatters::ConsoleCodes
      end
    end
  end
end
