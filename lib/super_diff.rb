require "patience_diff"
require "diff-lcs"

require_relative "super_diff/csi"

module SuperDiff
  autoload :ColorizedDocument, "super_diff/colorized_document"
  autoload :DiffFormatter, "super_diff/diff_formatter"
  autoload :DiffFormatters, "super_diff/diff_formatters"
  autoload :Differ, "super_diff/differ"
  autoload :Differs, "super_diff/differs"
  autoload(
    :NoOperationalSequencerAvailableError,
    "super_diff/no_operational_sequencer_available_error",
  )
  autoload :EqualityMatcher, "super_diff/equality_matcher"
  autoload :EqualityMatchers, "super_diff/equality_matchers"
  autoload :Helpers, "super_diff/helpers"
  autoload :ObjectInspection, "super_diff/object_inspection"
  autoload :OperationalSequencer, "super_diff/operational_sequencer"
  autoload :OperationalSequencers, "super_diff/operational_sequencers"
  autoload :OperationSequences, "super_diff/operation_sequences"
  autoload :Operations, "super_diff/operations"
end
