# frozen_string_literal: true

require 'attr_extras/explicit'
require 'date'

module SuperDiff
  autoload :Core, 'super_diff/core'
  autoload :Csi, 'super_diff/csi'
  autoload :Differs, 'super_diff/differs'
  autoload :EqualityMatchers, 'super_diff/equality_matchers'
  autoload :Errors, 'super_diff/errors'
  autoload :ObjectInspection, 'super_diff/object_inspection'
  autoload :OperationTreeBuilders, 'super_diff/operation_tree_builders'
  autoload :OperationTreeFlatteners, 'super_diff/operation_tree_flatteners'
  autoload :OperationTrees, 'super_diff/operation_trees'
  autoload :Operations, 'super_diff/operations'
  autoload :VERSION, 'super_diff/version'

  def self.const_missing(missing_const_name)
    if Core.const_defined?(missing_const_name)
      warn <<~WARNING
        WARNING: SuperDiff::#{missing_const_name} is deprecated and will be removed in the next major release.
        Please use SuperDiff::Core::#{missing_const_name} instead.
        #{caller_locations.join("\n")}
      WARNING
      Core.const_get(missing_const_name)
    elsif Basic.const_defined?(missing_const_name)
      warn <<~WARNING
        WARNING: SuperDiff::#{missing_const_name} is deprecated and will be removed in the next major release.
        Please use SuperDiff::Basic::#{missing_const_name} instead.
        #{caller_locations.join("\n")}
      WARNING
      Basic.const_get(missing_const_name)
    else
      super
    end
  end

  def self.configure
    yield configuration
  end

  def self.configuration
    @configuration ||= Core::Configuration.new
  end

  def self.diff(
    expected,
    actual,
    indent_level: 0,
    raise_if_nothing_applies: true
  )
    Core::DifferDispatcher.call(
      expected,
      actual,
      available_classes: configuration.extra_differ_classes,
      indent_level: indent_level,
      raise_if_nothing_applies: raise_if_nothing_applies
    )
  end

  def self.build_operation_tree_for(
    expected,
    actual,
    extra_operation_tree_builder_classes: [],
    raise_if_nothing_applies: false
  )
    Core::OperationTreeBuilderDispatcher.call(
      expected,
      actual,
      available_classes:
        configuration.extra_operation_tree_builder_classes +
          extra_operation_tree_builder_classes,
      raise_if_nothing_applies: raise_if_nothing_applies
    )
  end

  def self.find_operation_tree_for(value)
    SuperDiff::Core::OperationTreeFinder.call(
      value,
      available_classes: configuration.extra_operation_tree_classes
    )
  end

  def self.inspect_object(object, as_lines:, **rest)
    Core::RecursionGuard.guarding_recursion_of(object) do
      inspection_tree =
        Core::InspectionTreeBuilderDispatcher.call(
          object,
          available_classes: configuration.extra_inspection_tree_builder_classes
        )

      if as_lines
        inspection_tree.render_to_lines(object, **rest)
      else
        inspection_tree.render_to_string(object)
      end
    end
  end

  def self.time_like?(value)
    # Check for ActiveSupport's #acts_like_time? for their time-like objects
    # (like ActiveSupport::TimeWithZone).
    (value.respond_to?(:acts_like_time?) && value.acts_like_time?) ||
      value.is_a?(Time)
  end

  def self.date_like?(value)
    # Check for ActiveSupport's #acts_like_date? for their date-like objects
    # In case class is both time-like and date-like, we should treat it as
    # time-like. This is governed by the order of `Differs::DEFAULTS` entries
    (value.respond_to?(:acts_like_date?) && value.acts_like_date?) ||
      value.is_a?(Date)
  end

  def self.primitive?(value)
    case value
    when true, false, nil, Symbol, Numeric, Regexp, Class, Module, String
      true
    else
      false
    end
  end

  def self.insert_overrides(target_module, mod = nil, &block)
    target_module.prepend(mod || Module.new(&block))
  end

  def self.insert_singleton_overrides(target_module, mod = nil, &block)
    target_module.singleton_class.prepend(mod || Module.new(&block))
  end
end

require 'super_diff/basic'
