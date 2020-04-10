module SuperDiff
  module RSpec
    module Differs
      class HashIncluding < SuperDiff::Differs::Hash
        def self.applies_to?(expected, actual)
          SuperDiff::RSpec.a_hash_including_something?(expected) &&
            actual.is_a?(::Hash)
        end

        private

        def operational_sequencer_class
          OperationalSequencers::HashIncluding
        end
      end
    end
  end
end
