require_relative "../super_diff"

require_relative "rspec/differ"
require_relative "rspec/object_inspection/inspector_registry"
require_relative "rspec/object_inspection/inspectors"
require_relative "rspec/object_inspection/inspectors/partial_array"
require_relative "rspec/object_inspection/inspectors/partial_hash"
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
      value.is_a?(::RSpec::Matchers::AliasedMatcher) &&
        value.expecteds.one? &&
        value.expecteds.first.is_a?(::Hash)
    end

    def self.partial_array?(value)
      value.is_a?(::RSpec::Matchers::AliasedMatcher) &&
        !(value.expecteds.one? && value.expecteds.first.is_a?(::Hash))
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
