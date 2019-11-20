module SuperDiff
  module OperationalSequencers
    autoload :Array, "super_diff/operational_sequencers/array"
    autoload :Base, "super_diff/operational_sequencers/base"
    autoload :CustomObject, "super_diff/operational_sequencers/custom_object"
    autoload :DefaultObject, "super_diff/operational_sequencers/default_object"
    autoload :Hash, "super_diff/operational_sequencers/hash"
    # TODO: Where is this used?
    autoload(
      :MultilineString,
      "super_diff/operational_sequencers/multiline_string",
    )
    autoload :TimeLike, "super_diff/operational_sequencers/time_like"

    DEFAULTS = [Array, Hash, CustomObject].freeze
  end
end
