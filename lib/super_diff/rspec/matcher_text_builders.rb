module SuperDiff
  module RSpec
    module MatcherTextBuilders
      autoload :Base, "super_diff/rspec/matcher_text_builders/base"
      autoload(
        :BePredicate,
        "super_diff/rspec/matcher_text_builders/be_predicate"
      )
      autoload(
        :ContainExactly,
        "super_diff/rspec/matcher_text_builders/contain_exactly"
      )
      autoload(
        :HavePredicate,
        "super_diff/rspec/matcher_text_builders/have_predicate"
      )
      autoload :Match, "super_diff/rspec/matcher_text_builders/match"
      autoload(
        :RaiseError,
        "super_diff/rspec/matcher_text_builders/raise_error"
      )
      autoload(:RespondTo, "super_diff/rspec/matcher_text_builders/respond_to")
    end
  end
end
