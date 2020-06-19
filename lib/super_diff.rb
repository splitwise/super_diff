require "attr_extras/explicit"
require "diff-lcs"
require "patience_diff"

module SuperDiff
  autoload(
    :ColorizedDocumentExtensions,
    "super_diff/colorized_document_extensions",
  )
  autoload :OperationTreeFlatteners, "super_diff/operation_tree_flatteners"
  autoload :Configuration, "super_diff/configuration"
  autoload :Csi, "super_diff/csi"
  autoload :DiffFormatters, "super_diff/diff_formatters"
  autoload :Differs, "super_diff/differs"
  autoload :EqualityMatchers, "super_diff/equality_matchers"
  autoload :Errors, "super_diff/errors"
  autoload :GemVersion, "super_diff/gem_version"
  autoload :Helpers, "super_diff/helpers"
  autoload :ImplementationChecks, "super_diff/implementation_checks"
  autoload :Line, "super_diff/line"
  autoload :TieredLines, "super_diff/tiered_lines"
  autoload :TieredLinesElider, "super_diff/tiered_lines_elider"
  autoload :TieredLinesFormatter, "super_diff/tiered_lines_formatter"
  autoload :ObjectInspection, "super_diff/object_inspection"
  autoload :OperationTrees, "super_diff/operation_trees"
  autoload :OperationTreeBuilders, "super_diff/operation_tree_builders"
  autoload :Operations, "super_diff/operations"
  autoload :RecursionGuard, "super_diff/recursion_guard"

  def self.configure
    yield configuration
    configuration.updated
  end

  def self.configuration
    @_configuration ||= Configuration.new
  end

  def self.inspect_object(object, as_lines:, **rest)
    SuperDiff::RecursionGuard.guarding_recursion_of(object) do
      inspection_tree = ObjectInspection::InspectionTreeBuilders::Main.call(
        object
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

  def self.primitive?(value)
    case value
    when true, false, nil, Symbol, Numeric, Regexp, Class
      true
    else
      false
    end
  end

  def self.insert_overrides(target_module, mod = nil, &block)
    if mod
      target_module.prepend(mod)
    else
      target_module.prepend(Module.new(&block))
    end
  end

  def self.insert_singleton_overrides(target_module, mod = nil, &block)
    if mod
      target_module.singleton_class.prepend(mod)
    else
      target_module.singleton_class.prepend(Module.new(&block))
    end
  end
end
