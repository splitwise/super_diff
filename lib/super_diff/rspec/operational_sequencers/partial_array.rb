module SuperDiff
  module RSpec
    module OperationalSequencers
      class PartialArray < SuperDiff::OperationalSequencers::Array
        def self.applies_to?(value)
          value.is_a?(::RSpec::Matchers::AliasedMatcher) &&
            value.expected.is_a?(::Array)
        end

        def initialize(expected:, **rest)
          super

          @expected = expected.expected
        end
      end
    end
  end
end
