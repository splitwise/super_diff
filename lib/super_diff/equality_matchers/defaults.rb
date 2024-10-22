# frozen_string_literal: true

module SuperDiff
  module EqualityMatchers
    DEFAULTS = [
      Array,
      Hash,
      MultilineString,
      SinglelineString,
      Primitive,
      Default
    ].freeze
  end
end
