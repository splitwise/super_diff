require "super_diff"

module SuperDiff
  module RSpec
    autoload :AugmentedMatcher, "super_diff/rspec/augmented_matcher"
    autoload :Configuration, "super_diff/rspec/configuration"
    autoload :Differ, "super_diff/rspec/differ"
    autoload :Differs, "super_diff/rspec/differs"
    autoload :MatcherTextBuilders, "super_diff/rspec/matcher_text_builders"
    autoload :MatcherTextTemplate, "super_diff/rspec/matcher_text_template"
    autoload :ObjectInspection, "super_diff/rspec/object_inspection"
    autoload :OperationalSequencers, "super_diff/rspec/operational_sequencers"

    def self.configure
      yield configuration
    end

    def self.configuration
      SuperDiff.configuration
    end

    def self.a_hash_including_something?(value)
      fuzzy_object?(value) &&
        value.respond_to?(:expecteds) &&
        value.expecteds.one? &&
        value.expecteds.first.is_a?(::Hash)
    end

    def self.a_collection_including_something?(value)
      fuzzy_object?(value) &&
        value.respond_to?(:expecteds) &&
        !(value.expecteds.one? && value.expecteds.first.is_a?(::Hash))
    end

    def self.an_object_having_some_attributes?(value)
      fuzzy_object?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::HaveAttributes)
    end

    def self.a_collection_containing_exactly_something?(value)
      fuzzy_object?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::ContainExactly)
    end

    def self.a_kind_of_something?(value)
      fuzzy_object?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::BeAKindOf)
    end

    def self.an_instance_of_something?(value)
      fuzzy_object?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::BeAnInstanceOf)
    end

    def self.a_value_within_something?(value)
      fuzzy_object?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::BeWithin)
    end

    def self.fuzzy_object?(value)
      value.is_a?(::RSpec::Matchers::AliasedMatcher)
    end

    SuperDiff.configuration.tap do |config|
      config.add_extra_differ_classes(
        Differs::CollectionContainingExactly,
        Differs::CollectionIncluding,
        Differs::HashIncluding,
        Differs::ObjectHavingAttributes,
      )

      config.add_extra_operational_sequencer_classes(
        OperationalSequencers::CollectionContainingExactly,
        OperationalSequencers::CollectionIncluding,
        OperationalSequencers::HashIncluding,
        OperationalSequencers::ObjectHavingAttributes,
      )

      config.add_extra_inspector_classes(
        ObjectInspection::Inspectors::CollectionContainingExactly,
        ObjectInspection::Inspectors::CollectionIncluding,
        ObjectInspection::Inspectors::HashIncluding,
        ObjectInspection::Inspectors::InstanceOf,
        ObjectInspection::Inspectors::KindOf,
        ObjectInspection::Inspectors::ObjectHavingAttributes,
        ObjectInspection::Inspectors::Primitive,
        ObjectInspection::Inspectors::ValueWithin,
      )
    end
  end
end

require_relative "rspec/monkey_patches"

SuperDiff::Csi.color_enabled = ::RSpec.configuration.color_enabled?
