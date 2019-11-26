require "attr_extras/explicit"
require "diff-lcs"
require "patience_diff"

module SuperDiff
  autoload(
    :ColorizedDocumentExtensions,
    "super_diff/colorized_document_extensions",
  )
  autoload :Csi, "super_diff/csi"
  autoload :DiffFormatter, "super_diff/diff_formatter"
  autoload :DiffFormatters, "super_diff/diff_formatters"
  autoload :DiffLegendBuilder, "super_diff/diff_legend_builder"
  autoload :Differ, "super_diff/differ"
  autoload :Differs, "super_diff/differs"
  autoload :EqualityMatcher, "super_diff/equality_matcher"
  autoload :EqualityMatchers, "super_diff/equality_matchers"
  autoload :Helpers, "super_diff/helpers"
  autoload :NoDifferAvailableError, "super_diff/no_differ_available_error"
  autoload(
    :NoOperationalSequencerAvailableError,
    "super_diff/no_operational_sequencer_available_error",
  )
  autoload :ObjectInspection, "super_diff/object_inspection"
  autoload :OperationalSequencer, "super_diff/operational_sequencer"
  autoload :OperationalSequencers, "super_diff/operational_sequencers"
  autoload :OperationSequences, "super_diff/operation_sequences"
  autoload :Operations, "super_diff/operations"
  autoload :RecursionGuard, "super_diff/recursion_guard"
end

require "super_diff/colors"
