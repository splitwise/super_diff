require_relative "../super_diff"
require_relative "rspec/differ"
require_relative "rspec/monkey_patches"
require_relative "rspec/values_equal"

module SuperDiff
  module RSpec
    class << self
      attr_accessor :extra_differ_classes
      attr_accessor :extra_operational_sequencer_classes
      attr_accessor :extra_diff_formatter_classes
    end

    def self.configure
      yield self
    end

    def self.partial_hash?(value)
      value.is_a?(::RSpec::Matchers::AliasedMatcher) &&
        value.expecteds.one? &&
        value.expecteds.first.is_a?(::Hash)
    end

    def self.partial_array?(value)
      value.is_a?(::RSpec::Matchers::AliasedMatcher) && !value.expecteds.one?
    end

    self.extra_differ_classes = []
    self.extra_operational_sequencer_classes = []
    self.extra_diff_formatter_classes = []

    SuperDiff.values_equal = ValuesEqual
  end
end
