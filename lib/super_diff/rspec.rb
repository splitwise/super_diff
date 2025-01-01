# frozen_string_literal: true

require 'super_diff'

require 'super_diff/rspec/differs'
require 'super_diff/rspec/inspection_tree_builders'
require 'super_diff/rspec/operation_tree_builders'

module SuperDiff
  module RSpec
    autoload :AugmentedMatcher, 'super_diff/rspec/augmented_matcher'
    autoload :Configuration, 'super_diff/rspec/configuration'
    autoload :Differ, 'super_diff/rspec/differ'
    autoload :MatcherTextBuilders, 'super_diff/rspec/matcher_text_builders'
    autoload :MatcherTextTemplate, 'super_diff/rspec/matcher_text_template'
    autoload :ObjectInspection, 'super_diff/rspec/object_inspection'

    def self.configure(&block)
      SuperDiff.configure(&block)
    end

    def self.configuration
      SuperDiff.configuration
    end

    def self.a_hash_including_something?(value)
      aliased_matcher?(value) && value.respond_to?(:expecteds) &&
        value.expecteds.one? && value.expecteds.first.is_a?(::Hash)
    end

    # HINT: `a_hash_including` is an alias of `include` in the rspec-expectations gem.
    #       `hash_including` is an argument matcher in the rspec-mocks gem.
    def self.hash_including_something?(value)
      value.is_a?(::RSpec::Mocks::ArgumentMatchers::HashIncludingMatcher)
    end

    def self.a_collection_including_something?(value)
      aliased_matcher?(value) && value.respond_to?(:expecteds) &&
        !(value.expecteds.one? && value.expecteds.first.is_a?(::Hash))
    end

    def self.array_including_something?(value)
      value.is_a?(::RSpec::Mocks::ArgumentMatchers::ArrayIncludingMatcher)
    end

    def self.an_object_having_some_attributes?(value)
      aliased_matcher?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::HaveAttributes)
    end

    def self.a_collection_containing_exactly_something?(value)
      aliased_matcher?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::ContainExactly)
    end

    def self.a_kind_of_something?(value)
      aliased_matcher?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::BeAKindOf)
    end

    # HINT: `a_kind_of` is a matcher in the rspec-expectations gem.
    #       `kind_of` is an argument matcher in the rspec-mocks gem.
    def self.kind_of_something?(value)
      value.is_a?(::RSpec::Mocks::ArgumentMatchers::KindOf)
    end

    def self.an_instance_of_something?(value)
      aliased_matcher?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::BeAnInstanceOf)
    end

    # HINT: `an_instance_of` is a matcher in the rspec-expectations gem.
    #       `instance_of` is an argument matcher in the rspec-mocks gem.
    def self.instance_of_something?(value)
      value.is_a?(::RSpec::Mocks::ArgumentMatchers::InstanceOf)
    end

    def self.a_value_within_something?(value)
      aliased_matcher?(value) &&
        value.base_matcher.is_a?(::RSpec::Matchers::BuiltIn::BeWithin)
    end

    def self.aliased_matcher?(value)
      if SuperDiff::RSpec.rspec_version < '3.13.0'
        value.is_a?(::RSpec::Matchers::AliasedMatcher)
      else # See Github issue #250.
        !ordered_options?(value) && value.respond_to?(:base_matcher)
      end
    end

    def self.ordered_options?(value)
      defined?(::ActiveSupport::OrderedOptions) &&
        value.is_a?(::ActiveSupport::OrderedOptions)
    end

    def self.rspec_version
      @rspec_version ||=
        begin
          require 'rspec/core/version'
          Core::GemVersion.new(::RSpec::Core::Version::STRING)
        end
    end

    SuperDiff.configuration.tap do |config|
      config.prepend_extra_differ_classes(
        Differs::CollectionContainingExactly,
        Differs::CollectionIncluding,
        Differs::HashIncluding,
        Differs::ObjectHavingAttributes
      )

      config.prepend_extra_inspection_tree_builder_classes(
        InspectionTreeBuilders::Double,
        InspectionTreeBuilders::CollectionContainingExactly,
        InspectionTreeBuilders::CollectionIncluding,
        InspectionTreeBuilders::HashIncluding,
        InspectionTreeBuilders::InstanceOf,
        InspectionTreeBuilders::KindOf,
        InspectionTreeBuilders::ObjectHavingAttributes,
        # ObjectInspection::InspectionTreeBuilders::Primitive,
        InspectionTreeBuilders::ValueWithin,
        InspectionTreeBuilders::GenericDescribableMatcher
      )

      config.prepend_extra_operation_tree_builder_classes(
        OperationTreeBuilders::CollectionContainingExactly,
        OperationTreeBuilders::CollectionIncluding,
        OperationTreeBuilders::HashIncluding,
        OperationTreeBuilders::ObjectHavingAttributes
      )
    end
  end
end

require_relative 'rspec/monkey_patches'

RSpec.configuration.filter_gems_from_backtrace('super_diff')
