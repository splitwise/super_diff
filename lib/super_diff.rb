require "attr_extras/explicit"
require "diff-lcs"
require "patience_diff"

module SuperDiff
  autoload(
    :ColorizedDocumentExtensions,
    "super_diff/colorized_document_extensions",
  )
  autoload :Configuration, "super_diff/configuration"
  autoload :Csi, "super_diff/csi"
  autoload :DiffFormatters, "super_diff/diff_formatters"
  autoload :Differs, "super_diff/differs"
  autoload :EqualityMatchers, "super_diff/equality_matchers"
  autoload :Errors, "super_diff/errors"
  autoload :GemVersion, "super_diff/gem_version"
  autoload :Helpers, "super_diff/helpers"
  autoload :ImplementationChecks, "super_diff/implementation_checks"
  autoload :ObjectInspection, "super_diff/object_inspection"
  autoload :OperationTrees, "super_diff/operation_trees"
  autoload :OperationTreeBuilders, "super_diff/operation_tree_builders"
  autoload :Operations, "super_diff/operations"
  autoload :RecursionGuard, "super_diff/recursion_guard"

  def self.configure
    yield configuration
  end

  def self.configuration
    @_configuration ||= Configuration.new
  end

  def self.inspect_object(object, as_single_line:, indent_level: 0)
    ObjectInspection::Inspectors::Main.call(
      object,
      as_single_line: as_single_line,
      indent_level: indent_level,
    )
  end

  def self.time_like?(value)
    # Check for ActiveSupport's #acts_like_time? for their time-like objects
    # (like ActiveSupport::TimeWithZone).
    (value.respond_to?(:acts_like_time?) && value.acts_like_time?) ||
      value.is_a?(Time)
  end
end
