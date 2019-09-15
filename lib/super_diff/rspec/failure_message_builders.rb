module SuperDiff
  module RSpec
    module FailureMessageBuilders
      autoload :Base, "super_diff/rspec/failure_message_builders/base"
      autoload(
        :BePredicate,
        "super_diff/rspec/failure_message_builders/be_predicate",
      )
      autoload(
        :ContainExactly,
        "super_diff/rspec/failure_message_builders/contain_exactly",
      )
      autoload :Match, "super_diff/rspec/failure_message_builders/match"
      autoload(
        :RaiseError,
        "super_diff/rspec/failure_message_builders/raise_error",
      )
      autoload(
        :RespondTo,
        "super_diff/rspec/failure_message_builders/respond_to",
      )
    end
  end
end
