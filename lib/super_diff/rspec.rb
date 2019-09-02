require_relative "../super_diff"

require_relative "rspec/differ"

require_relative "rspec/differs/partial_array"
require_relative "rspec/differs/partial_hash"
require_relative "rspec/differs/partial_object"

require_relative "rspec/operational_sequencers/partial_array"
require_relative "rspec/operational_sequencers/partial_hash"
require_relative "rspec/operational_sequencers/partial_object"

require_relative "rspec/object_inspection/inspector_registry"
require_relative "rspec/object_inspection/inspectors"
require_relative "rspec/object_inspection/inspectors/partial_array"
require_relative "rspec/object_inspection/inspectors/partial_hash"
require_relative "rspec/object_inspection/inspectors/partial_object"

require_relative "rspec/failure_message_template"
require_relative "rspec/failure_message_builders/base"
require_relative "rspec/failure_message_builders/match"

require_relative "rspec/augmented_matcher"

require_relative "rspec/monkey_patches"

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

    def self.partial_placeholder?(value)
      value.is_a?(::RSpec::Matchers::AliasedMatcher)
    end

    self.extra_differ_classes = []
    self.extra_operational_sequencer_classes = []
    self.extra_diff_formatter_classes = []
  end
end

SuperDiff::ObjectInspection.inspector_registry =
  SuperDiff::RSpec::ObjectInspection::InspectorRegistry.new(
    SuperDiff::ObjectInspection.inspector_registry.to_h,
  )
