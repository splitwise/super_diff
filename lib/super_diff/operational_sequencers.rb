module SuperDiff
  module OperationalSequencers
    autoload :Array, "super_diff/operational_sequencers/array"
    autoload :Base, "super_diff/operational_sequencers/base"
    autoload :Hash, "super_diff/operational_sequencers/hash"
    autoload(
      :MultilineString,
      "super_diff/operational_sequencers/multiline_string",
    )
    autoload :Object, "super_diff/operational_sequencers/object"

    DEFAULTS = [Array, Hash].freeze
  end
end
