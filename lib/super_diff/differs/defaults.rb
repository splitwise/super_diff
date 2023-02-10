module SuperDiff
  module Differs
    DEFAULTS = [
      Array,
      Hash,
      TimeLike,
      MultilineString,
      CustomObject,
      DefaultObject
    ].freeze
  end
end
