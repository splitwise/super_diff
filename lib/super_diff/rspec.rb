require "super_diff"

module SuperDiff
  module RSpec
    autoload :AugmentedMatcher, "super_diff/rspec/augmented_matcher"
    autoload :Differ, "super_diff/rspec/differ"
    autoload :Differs, "super_diff/rspec/differs"
    autoload(
      :FailureMessageBuilders,
      "super_diff/rspec/failure_message_builders",
    )
    autoload(
      :FailureMessageTemplate,
      "super_diff/rspec/failure_message_template",
    )
    autoload :ObjectInspection, "super_diff/rspec/object_inspection"
    autoload :OperationalSequencers, "super_diff/rspec/operational_sequencers"

    class << self
      attr_accessor :extra_differ_classes
      attr_accessor :extra_operational_sequencer_classes
      attr_accessor :extra_diff_formatter_classes
    end

    def self.configure
      yield self
    end

    def self.partial_hash?(value)
      partial_placeholder?(value) &&
        value.respond_to?(:expecteds) &&
        value.expecteds.one? &&
        value.expecteds.first.is_a?(::Hash)
    end

    def self.partial_array?(value)
      partial_placeholder?(value) &&
        value.respond_to?(:expecteds) &&
        !(value.expecteds.one? && value.expecteds.first.is_a?(::Hash))
    end

    def self.partial_object?(value)
      partial_placeholder?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::HaveAttributes)
    end

    def self.collection_containing_exactly?(value)
      partial_placeholder?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::ContainExactly)
    end

    def self.partial_placeholder?(value)
      value.is_a?(::RSpec::Matchers::AliasedMatcher)
    end

    self.extra_differ_classes = []
    self.extra_operational_sequencer_classes = []
    self.extra_diff_formatter_classes = []
  end
end

require_relative "rspec/monkey_patches"

SuperDiff::ObjectInspection.inspector_finder =
  SuperDiff::RSpec::ObjectInspection::InspectorFinder
