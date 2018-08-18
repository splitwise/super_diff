require_relative "equality_matchers/detector"
require_relative "equality_matchers/object"

module SuperDiff
  class EqualityMatcher
    def self.call(expected:, actual:)
      new(expected: expected, actual: actual).call
    end

    def initialize(expected:, actual:)
      @expected = expected
      @actual = actual
    end

    def call
      if expected.is_a?(actual.class)
        EqualityMatchers::Detector.call(expected.class).call(expected, actual)
      else
        EqualityMatchers::Object.call(expected, actual)
      end
    end

    private

    attr_reader :expected, :actual
  end
end
