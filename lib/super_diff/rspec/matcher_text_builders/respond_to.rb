module SuperDiff
  module RSpec
    module MatcherTextBuilders
      class RespondTo < Base
        def initialize(
          expected_arity:,
          arbitrary_keywords:,
          expected_keywords:,
          unlimited_arguments:,
          **rest
        )
          super(**rest)
          @expected_arity = expected_arity
          @arbitrary_keywords = arbitrary_keywords
          @expected_keywords = expected_keywords
          @unlimited_arguments = unlimited_arguments
        end

        protected

        def add_expected_value_to(template, expected)
          template.add_text " "
          template.add_list_in_color(expected_color, expected)
        end

        def add_extra_after_expected_to(template)
          add_arity_clause_to(template) if expected_arity

          if arbitrary_keywords?
            add_arbitrary_keywords_clause_to(template)
          elsif has_expected_keywords?
            add_keywords_clause_to(template)
          end

          add_unlimited_arguments_clause_to(template) if unlimited_arguments?
        end

        private

        attr_reader :expected_arity, :expected_keywords

        def arbitrary_keywords?
          @arbitrary_keywords
        end

        def has_expected_keywords?
          expected_keywords && expected_keywords.count > 0
        end

        def unlimited_arguments?
          @unlimited_arguments
        end

        def add_arity_clause_to(template)
          template.add_text " with "
          template.add_text_in_color expected_color, expected_arity
          template.add_text " "
          template.add_text pluralize("argument", expected_arity)
        end

        def add_arbitrary_keywords_clause_to(template)
          template.add_text " with "
          template.add_text_in_color expected_color, "any"
          template.add_text " keywords"
        end

        def add_keywords_clause_to(template)
          template.add_text " with "
          template.add_text pluralize("keyword", expected_keywords.length)
          template.add_text " "
          template.add_list_in_color expected_color, expected_keywords
        end

        def add_unlimited_arguments_clause_to(template)
          if arbitrary_keywords? || has_expected_keywords?
            template.add_text " and "
          else
            template.add_text " with "
          end

          template.add_text_in_color expected_color, "unlimited"
          template.add_text " arguments"
        end

        def pluralize(word, count)
          if count == 1
            word
          else
            "#{word}s"
          end
        end
      end
    end
  end
end
