module SuperDiff
  module Differs
    DEFAULTS = [
      Array,
      Hash,
      TimeLike,
      DateLike,
      MultilineString,
      CustomObject,
      DefaultObject
    ].freeze
  end
end
