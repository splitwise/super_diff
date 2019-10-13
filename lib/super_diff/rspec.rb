require "super_diff"

module SuperDiff
  module RSpec
    autoload :AugmentedMatcher, "super_diff/rspec/augmented_matcher"
    autoload :Configuration, "super_diff/rspec/configuration"
    autoload :Differ, "super_diff/rspec/differ"
    autoload :Differs, "super_diff/rspec/differs"
    autoload(
      :ExceptionMessageFormatters,
      "super_diff/rspec/exception_message_formatters",
    )
    autoload(
      :ExceptionMessageFormatterMap,
      "super_diff/rspec/exception_message_formatter_map",
    )
    autoload :MatcherTextBuilders, "super_diff/rspec/matcher_text_builders"
    autoload :MatcherTextTemplate, "super_diff/rspec/matcher_text_template"
    autoload :ObjectInspection, "super_diff/rspec/object_inspection"
    autoload :OperationalSequencers, "super_diff/rspec/operational_sequencers"
    autoload :StringTagger, "super_diff/rspec/string_tagger"

    class << self
      attr_accessor :extra_differ_classes
      attr_accessor :extra_operational_sequencer_classes
      attr_accessor :extra_diff_formatter_classes
    end

    def self.configure
      yield configuration
    end

    def self.configuration
      @_configuration ||= Configuration.new
    end

    def self.format_exception_message(exception_message)
      exception_message_formatter_map.
        call(exception_message).
        call(exception_message)
    end

    def self.exception_message_formatter_map
      @_exception_message_formatter_map ||= ExceptionMessageFormatterMap.new
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

    def self.fuzzy_object?(value)
      value.is_a?(::RSpec::Matchers::AliasedMatcher)
    end
  end
end

require_relative "rspec/monkey_patches"

SuperDiff::ObjectInspection.map.prepend(
  SuperDiff::RSpec::ObjectInspection::MapExtension,
)

SuperDiff::Csi.color_enabled = RSpec.configuration.color_enabled?
